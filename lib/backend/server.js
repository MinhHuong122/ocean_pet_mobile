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

const app = express();

app.use(cors());
app.use(express.json());

// Cấu hình kết nối MySQL với xử lý lỗi
const dbConfig = {
    host: '127.0.0.1', // Sử dụng IPv4 thay vì localhost để tránh vấn đề IPv6
    user: 'root',
    password: 'your_mysql_password', // Thay bằng mật khẩu MySQL thực tế
    database: 'ocean_pet_app',
    port: 3306,
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
        const [result] = await db.query('INSERT INTO users (email, password, name, provider) VALUES (?, ?, ?, ?)', 
            [email, hashedPassword, name, 'local']);
        res.status(201).json({ message: 'Đăng ký thành công', userId: result.insertId });
    } catch (err) {
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