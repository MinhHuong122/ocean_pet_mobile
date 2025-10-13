const express = require('express');
const mysql = require('mysql2/promise'); // Sử dụng promise để xử lý async/await
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const FacebookStrategy = require('passport-facebook').Strategy;
const cors = require('cors');
const { OAuth2Client } = require('google-auth-library');
const fetch = require('node-fetch');
const nodemailer = require('nodemailer');

const app = express();

// Cấu hình email transporter (sử dụng Gmail)
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'tutumanhmanh@gmail.com', // Thay bằng email của bạn
        pass: 'wtel pqym azfd fdrk' // Thay bằng App Password của Gmail
    }
});

// Lưu trữ OTP tạm thời (trong production nên dùng Redis)
const otpStore = new Map(); // { email: { otp: '123456', expiresAt: timestamp, userId: id } }

app.use(cors());
app.use(express.json());

// Cấu hình kết nối MySQL với xử lý lỗi
const dbConfig = {
    host: 'localhost',
    user: 'root',
    password: '012254',
    database: 'ocean_pet_app',
    port: 3307, // Đã đổi sang 3307 theo cấu hình MySQL trên máy bạn
};

let db;
async function connectDB() {
    try {
        db = await mysql.createPool(dbConfig);
        console.log('Kết nối MySQL thành công!');
    } catch (err) {
        console.error('Lỗi kết nối MySQL:', err.message);
        process.exit(1); // Thoát nếu không kết nối được
    }
}
connectDB();

// Health check endpoint - Kiểm tra server và database đang chạy
app.get('/', async (req, res) => {
    try {
        await db.query('SELECT 1'); // Test database connection
        res.json({ 
            status: 'OK', 
            message: 'Server và Database đã kết nối thành công!',
            timestamp: new Date().toISOString()
        });
    } catch (err) {
        res.status(500).json({ 
            status: 'ERROR', 
            message: 'Database chưa kết nối',
            error: err.message 
        });
    }
});

// Cấu hình Passport cho Google
passport.use(new GoogleStrategy({
    clientID: 'YOUR_GOOGLE_CLIENT_ID', // Thay bằng Client ID thực tế
    clientSecret: 'YOUR_GOOGLE_CLIENT_SECRET', // Thay bằng Client Secret thực tế
    callbackURL: 'http://localhost:3000/auth/google/callback'
}, async (accessToken, refreshToken, profile, done) => {
    const { id, displayName, emails } = profile;
    const email = emails[0].value;
    let [users] = await db.query('SELECT * FROM users WHERE provider_id = ?', [id]);
    if (users.length === 0) {
        [result] = await db.query('INSERT INTO users (email, name, provider, provider_id) VALUES (?, ?, ?, ?)', 
            [email, displayName, 'google', id]);
        users = [{ id: result.insertId, email, name: displayName, provider: 'google', provider_id: id }];
    }
    done(null, users[0]);
}));

// Cấu hình Passport cho Facebook
passport.use(new FacebookStrategy({
    clientID: 'YOUR_FACEBOOK_APP_ID', // Thay bằng App ID thực tế
    clientSecret: 'YOUR_FACEBOOK_APP_SECRET', // Thay bằng App Secret thực tế
    callbackURL: 'http://localhost:3000/auth/facebook/callback',
    profileFields: ['id', 'displayName', 'emails']
}, async (accessToken, refreshToken, profile, done) => {
    const { id, displayName, emails } = profile;
    const email = emails ? emails[0].value : `${id}@facebook.com`;
    let [users] = await db.query('SELECT * FROM users WHERE provider_id = ?', [id]);
    if (users.length === 0) {
        [result] = await db.query('INSERT INTO users (email, name, provider, provider_id) VALUES (?, ?, ?, ?)', 
            [email, displayName, 'facebook', id]);
        users = [{ id: result.insertId, email, name: displayName, provider: 'facebook', provider_id: id }];
    }
    done(null, users[0]);
}));

// API đăng ký
app.post('/register', async (req, res) => {
    const { email, password, name } = req.body;
    try {
        const [existingUsers] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (existingUsers.length > 0) {
            return res.status(400).json({ error: 'Email đã tồn tại' });
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await db.query('INSERT INTO users (email, password, name, provider, is_verified) VALUES (?, ?, ?, ?, ?)', 
            [email, hashedPassword, name, 'local', false]);
        
        // Tạo và gửi OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString(); // 6 số
        const expiresAt = Date.now() + 10 * 60 * 1000; // 10 phút
        otpStore.set(email, { otp, expiresAt, userId: result.insertId });

        // Gửi email OTP
        try {
            await transporter.sendMail({
                from: '"Ocean Pet" <tutumanhmanh@gmail.com>',
                to: email,
                subject: 'Mã xác thực OTP - Ocean Pet',
                html: `
                    <h2>Xin chào ${name}!</h2>
                    <p>Mã OTP của bạn là: <strong style="font-size: 24px; color: #8B5CF6;">${otp}</strong></p>
                    <p>Mã này sẽ hết hạn sau 10 phút.</p>
                    <p>Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này.</p>
                `
            });
            console.log(`✅ OTP đã gửi thành công đến ${email}: ${otp}`);
        } catch (emailErr) {
            console.error('❌ Lỗi gửi email:', emailErr.message);
            console.log(`⚠️ Mã OTP để test (không gửi được email): ${otp}`);
        }

        res.status(201).json({ 
            message: 'Đăng ký thành công. Vui lòng kiểm tra email để xác thực.', 
            userId: result.insertId,
            email: email
        });
    } catch (err) {
        console.error('Lỗi đăng ký:', err);
        res.status(500).json({ error: 'Lỗi server, vui lòng thử lại', details: err.message });
    }
});

// API gửi lại OTP
app.post('/resend-otp', async (req, res) => {
    const { email } = req.body;
    try {
        const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(404).json({ error: 'Email không tồn tại' });
        }

        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = Date.now() + 10 * 60 * 1000;
        otpStore.set(email, { otp, expiresAt, userId: users[0].id });

        try {
            await transporter.sendMail({
                from: '"Ocean Pet" <tutumanhmanh@gmail.com>',
                to: email,
                subject: 'Mã xác thực OTP mới - Ocean Pet',
                html: `
                    <h2>Mã OTP mới của bạn</h2>
                    <p>Mã OTP: <strong style="font-size: 24px; color: #8B5CF6;">${otp}</strong></p>
                    <p>Mã này sẽ hết hạn sau 10 phút.</p>
                `
            });
            console.log(`✅ OTP đã gửi lại thành công đến ${email}: ${otp}`);
        } catch (emailErr) {
            console.error('❌ Lỗi gửi email:', emailErr.message);
            console.log(`⚠️ Mã OTP để test (không gửi được email): ${otp}`);
        }

        res.json({ message: 'Mã OTP đã được gửi lại' });
    } catch (err) {
        console.error('Lỗi gửi lại OTP:', err);
        res.status(500).json({ error: 'Lỗi server, vui lòng thử lại' });
    }
});

// API xác thực OTP
app.post('/verify-otp', async (req, res) => {
    const { email, otp } = req.body;
    try {
        const storedOTP = otpStore.get(email);
        
        if (!storedOTP) {
            return res.status(400).json({ error: 'Mã OTP không tồn tại hoặc đã hết hạn' });
        }

        if (Date.now() > storedOTP.expiresAt) {
            otpStore.delete(email);
            return res.status(400).json({ error: 'Mã OTP đã hết hạn' });
        }

        if (storedOTP.otp !== otp) {
            return res.status(400).json({ error: 'Mã OTP không chính xác' });
        }

        // Cập nhật trạng thái verified
        await db.query('UPDATE users SET is_verified = ? WHERE id = ?', [true, storedOTP.userId]);
        
        // Xóa OTP sau khi xác thực thành công
        otpStore.delete(email);

        res.json({ message: 'Xác thực thành công!' });
    } catch (err) {
        console.error('Lỗi xác thực OTP:', err);
        res.status(500).json({ error: 'Lỗi server, vui lòng thử lại' });
    }
});

// API lấy thông tin user
app.get('/user/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const [users] = await db.query(
            'SELECT id, email, name, provider, provider_id, avatar_url, created_at FROM users WHERE id = ?', 
            [id]
        );
        
        if (users.length === 0) {
            return res.status(404).json({ error: 'Người dùng không tồn tại' });
        }

        const user = users[0];
        res.json({ 
            success: true,
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
                provider: user.provider,
                providerId: user.provider_id,
                avatarUrl: user.avatar_url,
                createdAt: user.created_at
            }
        });
    } catch (err) {
        console.error('Lỗi lấy thông tin user:', err);
        res.status(500).json({ error: 'Lỗi server, vui lòng thử lại' });
    }
});

// API cập nhật thông tin user
app.put('/user/:id', async (req, res) => {
    const { id } = req.params;
    const { name, avatarUrl } = req.body;
    
    try {
        await db.query(
            'UPDATE users SET name = ?, avatar_url = ? WHERE id = ?',
            [name, avatarUrl, id]
        );
        
        res.json({ 
            success: true,
            message: 'Cập nhật thông tin thành công',
            user: { id, name, avatarUrl }
        });
    } catch (err) {
        console.error('Lỗi cập nhật user:', err);
        res.status(500).json({ error: 'Lỗi server, vui lòng thử lại' });
    }
});

// API đăng nhập
app.post('/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const [users] = await db.query('SELECT * FROM users WHERE email = ? AND provider = ?', [email, 'local']);
        if (users.length === 0) return res.status(401).json({ error: 'Email hoặc mật khẩu sai' });

        const user = users[0];
        if (await bcrypt.compare(password, user.password)) {
            const token = jwt.sign({ id: user.id, email: user.email }, 'your_jwt_secret', { expiresIn: '1h' });
            res.json({ token, user: { id: user.id, email: user.email, name: user.name } });
        } else {
            res.status(401).json({ error: 'Email hoặc mật khẩu sai' });
        }
    } catch (err) {
        res.status(500).json({ error: 'Lỗi server, vui lòng thử lại' });
    }
});

// API Google token
const googleClient = new OAuth2Client('YOUR_GOOGLE_CLIENT_ID'); // Thay bằng Client ID thực tế
app.post('/auth/google/token', async (req, res) => {
    const { accessToken } = req.body;
    try {
        const ticket = await googleClient.verifyIdToken({
            idToken: accessToken,
            audience: 'YOUR_GOOGLE_CLIENT_ID',
        });
        const payload = ticket.getPayload();
        const { sub: googleId, email, name } = payload;
        let [users] = await db.query('SELECT * FROM users WHERE provider_id = ?', [googleId]);
        if (users.length === 0) {
            [result] = await db.query('INSERT INTO users (email, name, provider, provider_id) VALUES (?, ?, ?, ?)', 
                [email, name, 'google', googleId]);
            users = [{ id: result.insertId, email, name, provider: 'google', provider_id: googleId }];
        }
        const token = jwt.sign({ id: users[0].id, email: users[0].email }, 'your_jwt_secret', { expiresIn: '1h' });
        res.json({ token, user: users[0] });
    } catch (err) {
        res.status(401).json({ error: 'Xác thực Google thất bại' });
    }
});

// API Facebook token
app.post('/auth/facebook/token', async (req, res) => {
    const { accessToken } = req.body;
    try {
        const response = await fetch(`https://graph.facebook.com/me?access_token=${accessToken}&fields=id,name,email`);
        const data = await response.json();
        if (data.error) {
            return res.status(401).json({ error: 'Xác thực Facebook thất bại' });
        }
        const { id, name, email } = data;
        let [users] = await db.query('SELECT * FROM users WHERE provider_id = ?', [id]);
        if (users.length === 0) {
            [result] = await db.query('INSERT INTO users (email, name, provider, provider_id) VALUES (?, ?, ?, ?)', 
                [email || `${id}@facebook.com`, name, 'facebook', id]);
            users = [{ id: result.insertId, email: email || `${id}@facebook.com`, name, provider: 'facebook', provider_id: id }];
        }
        const token = jwt.sign({ id: users[0].id, email: users[0].email }, 'your_jwt_secret', { expiresIn: '1h' });
        res.json({ token, user: users[0] });
    } catch (err) {
        res.status(401).json({ error: 'Xác thực Facebook thất bại' });
    }
});

// API Google OAuth flow
app.get('/auth/google', passport.authenticate('google', { scope: ['profile', 'email'] }));
app.get('/auth/google/callback', passport.authenticate('google'), (req, res) => {
    const token = jwt.sign({ id: req.user.id, email: req.user.email }, 'your_jwt_secret', { expiresIn: '1h' });
    res.redirect(`yourapp://login?token=${token}`);
});

// API Facebook OAuth flow
app.get('/auth/facebook', passport.authenticate('facebook', { scope: ['email'] }));
app.get('/auth/facebook/callback', passport.authenticate('facebook'), (req, res) => {
    const token = jwt.sign({ id: req.user.id, email: req.user.email }, 'your_jwt_secret', { expiresIn: '1h' });
    res.redirect(`yourapp://login?token=${token}`);
});

// Khởi động server
app.listen(3000, () => console.log('Server chạy trên cổng 3000'));