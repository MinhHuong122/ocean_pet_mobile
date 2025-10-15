// =============================================
// OCEAN PET - Backend Server (Node.js + Express + MySQL)
// File: server.js
// =============================================

const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Database connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'ocean_pet',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Email transporter
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  }
});

// Helper: Generate OTP
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Helper: Send OTP Email
async function sendOTPEmail(email, otp) {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Ocean Pet - Mã xác thực OTP',
    html: `
      <h2>Xác thực tài khoản Ocean Pet</h2>
      <p>Mã OTP của bạn là: <strong>${otp}</strong></p>
      <p>Mã này sẽ hết hạn sau 10 phút.</p>
    `
  };
  await transporter.sendMail(mailOptions);
}

// Middleware: Verify JWT Token
function authenticateToken(req, res, next) {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ success: false, message: 'Token không hợp lệ' });
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ success: false, message: 'Token hết hạn' });
    }
    req.user = user;
    next();
  });
}

// =============================================
// AUTHENTICATION ROUTES
// =============================================

// POST /register - Đăng ký
app.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  
  try {
    // Kiểm tra email đã tồn tại
    const [existing] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(400).json({ success: false, message: 'Email đã được sử dụng' });
    }
    
    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Generate OTP
    const otp = generateOTP();
    const otpExpiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 phút
    
    // Insert user
    const [result] = await pool.query(
      'INSERT INTO users (name, email, password, provider, otp_code, otp_expires_at) VALUES (?, ?, ?, ?, ?, ?)',
      [name, email, hashedPassword, 'email', otp, otpExpiresAt]
    );
    
    // Send OTP email
    await sendOTPEmail(email, otp);
    
    res.json({
      success: true,
      message: 'Đăng ký thành công. Vui lòng kiểm tra email để xác thực.',
      userId: result.insertId
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// POST /verify-otp - Xác thực OTP
app.post('/verify-otp', async (req, res) => {
  const { email, otp } = req.body;
  
  try {
    const [users] = await pool.query(
      'SELECT id, otp_code, otp_expires_at FROM users WHERE email = ?',
      [email]
    );
    
    if (users.length === 0) {
      return res.status(404).json({ success: false, message: 'Email không tồn tại' });
    }
    
    const user = users[0];
    
    if (user.otp_code !== otp) {
      return res.status(400).json({ success: false, message: 'Mã OTP không đúng' });
    }
    
    if (new Date() > new Date(user.otp_expires_at)) {
      return res.status(400).json({ success: false, message: 'Mã OTP đã hết hạn' });
    }
    
    // Update user as verified
    await pool.query(
      'UPDATE users SET is_verified = TRUE, otp_code = NULL, otp_expires_at = NULL WHERE id = ?',
      [user.id]
    );
    
    res.json({ success: true, message: 'Xác thực thành công' });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// POST /resend-otp - Gửi lại OTP
app.post('/resend-otp', async (req, res) => {
  const { email } = req.body;
  
  try {
    const [users] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
    if (users.length === 0) {
      return res.status(404).json({ success: false, message: 'Email không tồn tại' });
    }
    
    const otp = generateOTP();
    const otpExpiresAt = new Date(Date.now() + 10 * 60 * 1000);
    
    await pool.query(
      'UPDATE users SET otp_code = ?, otp_expires_at = ? WHERE email = ?',
      [otp, otpExpiresAt, email]
    );
    
    await sendOTPEmail(email, otp);
    
    res.json({ success: true, message: 'Đã gửi lại mã OTP' });
  } catch (error) {
    console.error('Resend OTP error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// POST /login - Đăng nhập
app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  
  try {
    const [users] = await pool.query(
      'SELECT id, name, email, password, avatar_url, is_verified FROM users WHERE email = ? AND provider = ?',
      [email, 'email']
    );
    
    if (users.length === 0) {
      return res.status(401).json({ success: false, message: 'Email hoặc mật khẩu không đúng' });
    }
    
    const user = users[0];
    
    if (!user.is_verified) {
      return res.status(403).json({ success: false, message: 'Tài khoản chưa được xác thực' });
    }
    
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ success: false, message: 'Email hoặc mật khẩu không đúng' });
    }
    
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    res.json({
      success: true,
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        avatarUrl: user.avatar_url
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// =============================================
// USER ROUTES
// =============================================

// GET /user/:userId - Lấy thông tin user
app.get('/user/:userId', async (req, res) => {
  const { userId } = req.params;
  
  try {
    const [users] = await pool.query(
      'SELECT id, name, email, avatar_url FROM users WHERE id = ?',
      [userId]
    );
    
    if (users.length === 0) {
      return res.status(404).json({ success: false, message: 'User không tồn tại' });
    }
    
    res.json({ success: true, user: users[0] });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// PUT /user/:userId - Cập nhật thông tin user
app.put('/user/:userId', async (req, res) => {
  const { userId } = req.params;
  const { name, avatarUrl } = req.body;
  
  try {
    await pool.query(
      'UPDATE users SET name = ?, avatar_url = ? WHERE id = ?',
      [name, avatarUrl, userId]
    );
    
    const [users] = await pool.query(
      'SELECT id, name, email, avatar_url FROM users WHERE id = ?',
      [userId]
    );
    
    res.json({
      success: true,
      message: 'Cập nhật thành công',
      user: users[0]
    });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// =============================================
// FOLDERS ROUTES
// =============================================

// GET /folders/:userId - Lấy danh sách folders
app.get('/folders/:userId', async (req, res) => {
  const { userId } = req.params;
  
  try {
    const [folders] = await pool.query(
      'SELECT id, name, icon, color FROM folders WHERE user_id = ? ORDER BY name',
      [userId]
    );
    
    res.json({ success: true, folders });
  } catch (error) {
    console.error('Get folders error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// POST /folders/sync - Đồng bộ folders từ selected pets
app.post('/folders/sync', async (req, res) => {
  const { userId, selectedPets } = req.body;
  
  try {
    // Xóa folders cũ
    await pool.query('DELETE FROM folders WHERE user_id = ?', [userId]);
    
    // Icon và color mapping
    const petMapping = {
      'Mèo': { icon: '🐱', color: '#EC4899' },
      'Cá': { icon: '🐠', color: '#60A5FA' },
      'Rắn': { icon: '🐍', color: '#FB7185' },
      'Rùa': { icon: '🐢', color: '#34D399' },
      'Heo': { icon: '🐷', color: '#F59E42' },
      'Thỏ': { icon: '🐰', color: '#10B981' },
      'Chó': { icon: '🐕', color: '#8B5CF6' },
      'Vẹt': { icon: '🦜', color: '#EC4899' },
      'Hamster': { icon: '🐹', color: '#B45309' }
    };
    
    // Thêm folders mới
    for (const pet of selectedPets) {
      const mapping = petMapping[pet] || { icon: '🐾', color: '#8E97FD' };
      await pool.query(
        'INSERT INTO folders (user_id, name, icon, color) VALUES (?, ?, ?, ?)',
        [userId, pet, mapping.icon, mapping.color]
      );
    }
    
    res.json({ success: true, message: 'Đã đồng bộ thư mục' });
  } catch (error) {
    console.error('Sync folders error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// =============================================
// DIARY ROUTES
// =============================================

// GET /diary/:userId - Lấy tất cả diary entries
app.get('/diary/:userId', async (req, res) => {
  const { userId } = req.params;
  
  try {
    const [entries] = await pool.query(`
      SELECT 
        de.*,
        f.name as folder_name,
        GROUP_CONCAT(di.image_url) as images
      FROM diary_entries de
      LEFT JOIN folders f ON de.folder_id = f.id
      LEFT JOIN diary_images di ON de.id = di.diary_entry_id
      WHERE de.user_id = ? AND de.is_deleted = FALSE
      GROUP BY de.id
      ORDER BY de.entry_date DESC, de.entry_time DESC
    `, [userId]);
    
    // Parse images từ string thành array
    const parsedEntries = entries.map(entry => ({
      ...entry,
      images: entry.images ? entry.images.split(',') : []
    }));
    
    res.json({ success: true, entries: parsedEntries });
  } catch (error) {
    console.error('Get diary error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// POST /diary - Thêm diary entry
app.post('/diary', async (req, res) => {
  const { userId, folderId, title, description, category, entryDate, entryTime, bgColor, password, images } = req.body;
  
  try {
    const hashedPassword = password ? await bcrypt.hash(password, 10) : null;
    
    const [result] = await pool.query(`
      INSERT INTO diary_entries 
      (user_id, folder_id, title, description, category, entry_date, entry_time, bg_color, has_password, password)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [userId, folderId, title, description, category, entryDate, entryTime, bgColor, !!password, hashedPassword]);
    
    const entryId = result.insertId;
    
    // Thêm images nếu có
    if (images && images.length > 0) {
      for (let i = 0; i < images.length; i++) {
        await pool.query(
          'INSERT INTO diary_images (diary_entry_id, image_url, display_order) VALUES (?, ?, ?)',
          [entryId, images[i], i]
        );
      }
    }
    
    res.json({ success: true, message: 'Đã thêm nhật ký', entryId });
  } catch (error) {
    console.error('Add diary error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// PUT /diary/:entryId - Cập nhật diary entry
app.put('/diary/:entryId', async (req, res) => {
  const { entryId } = req.params;
  const { title, description, category, folderId, bgColor } = req.body;
  
  try {
    await pool.query(`
      UPDATE diary_entries 
      SET title = ?, description = ?, category = ?, folder_id = ?, bg_color = ?
      WHERE id = ?
    `, [title, description, category, folderId, bgColor, entryId]);
    
    res.json({ success: true, message: 'Đã cập nhật' });
  } catch (error) {
    console.error('Update diary error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// DELETE /diary/:entryId - Soft delete (vào thùng rác)
app.delete('/diary/:entryId', async (req, res) => {
  const { entryId } = req.params;
  
  try {
    await pool.query(`
      UPDATE diary_entries 
      SET is_deleted = TRUE, deleted_at = NOW()
      WHERE id = ?
    `, [entryId]);
    
    res.json({ success: true, message: 'Đã chuyển vào thùng rác' });
  } catch (error) {
    console.error('Delete diary error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// GET /diary/trash/:userId - Lấy entries trong thùng rác
app.get('/diary/trash/:userId', async (req, res) => {
  const { userId } = req.params;
  
  try {
    const [entries] = await pool.query(`
      SELECT 
        de.*,
        DATEDIFF(DATE_ADD(de.deleted_at, INTERVAL 30 DAY), NOW()) as days_left
      FROM diary_entries de
      WHERE de.user_id = ? 
      AND de.is_deleted = TRUE
      AND de.deleted_at > DATE_SUB(NOW(), INTERVAL 30 DAY)
      ORDER BY de.deleted_at DESC
    `, [userId]);
    
    res.json({ success: true, trashedEntries: entries });
  } catch (error) {
    console.error('Get trash error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// POST /diary/restore/:entryId - Khôi phục từ thùng rác
app.post('/diary/restore/:entryId', async (req, res) => {
  const { entryId } = req.params;
  
  try {
    await pool.query(`
      UPDATE diary_entries 
      SET is_deleted = FALSE, deleted_at = NULL
      WHERE id = ?
    `, [entryId]);
    
    res.json({ success: true, message: 'Đã khôi phục' });
  } catch (error) {
    console.error('Restore diary error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// DELETE /diary/permanent/:entryId - Xóa vĩnh viễn
app.delete('/diary/permanent/:entryId', async (req, res) => {
  const { entryId } = req.params;
  
  try {
    await pool.query('DELETE FROM diary_entries WHERE id = ?', [entryId]);
    
    res.json({ success: true, message: 'Đã xóa vĩnh viễn' });
  } catch (error) {
    console.error('Permanent delete error:', error);
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

// =============================================
// START SERVER
// =============================================

app.listen(PORT, () => {
  console.log(`✅ Ocean Pet Server running on port ${PORT}`);
});
