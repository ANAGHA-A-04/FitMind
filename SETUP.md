# FitMind - Setup Guide

## Prerequisites
- **Node.js** (v18 or later) - [Download](https://nodejs.org/)
- **Flutter SDK** (v3.11 or later) - [Install Guide](https://flutter.dev/docs/get-started/install)
- **MongoDB Atlas Account** (free) - [Sign up](https://www.mongodb.com/cloud/atlas/register)

---

## 🚀 Setup Instructions

### 1️⃣ Backend Setup

```bash
# Navigate to backend folder
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env file with your credentials
# - MONGODB_URI: Get from MongoDB Atlas (see below)
# - JWT_SECRET: Use any random secure string
```

**Get MongoDB URI:**
1. Go to [MongoDB Atlas](https://cloud.mongodb.com)
2. Create a free cluster (if you don't have one)
3. Click "Connect" → "Connect your application"
4. Copy the connection string
5. Replace `<password>` with your database password
6. Paste in `.env` file

**Start Backend:**
```bash
npm start
```
You should see: `✅ MongoDB Connected`

---

### 2️⃣ Frontend Setup

```bash
# Navigate to project root
cd ..

# Get Flutter dependencies
flutter pub get

# Run the app (make sure backend is running first!)
flutter run
```

---

## 📡 API Endpoints

**Base URL:** `http://localhost:5000/api`

- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user  
- `GET /auth/me` - Get user profile (Protected)

---

## 🧪 Testing

### Backend Only (Postman)
1. Start backend: `npm start`
2. Import requests in Postman
3. Test endpoints

### Full App
1. Start backend in one terminal
2. Run Flutter app in another terminal
3. Register/Login from the app

---

## 📱 Device Testing

**For Android Emulator:** Works with `http://localhost:5000` or `http://10.0.2.2:5000`

**For Physical Device:** 
1. Find your computer's local IP address
   - Windows: `ipconfig` (look for IPv4)
   - Mac/Linux: `ifconfig`
2. Update `lib/services/auth_service.dart` line 7:
   ```dart
   static const String baseUrl = 'http://YOUR_LOCAL_IP:5000/api';
   ```
3. Make sure both devices are on the same WiFi network

---

## 🛠️ Troubleshooting

**Backend won't start:**
- Check if MongoDB URI is correct in `.env`
- Make sure port 5000 is not already in use

**Flutter build errors:**
- Run `flutter clean && flutter pub get`
- Check Flutter SDK version: `flutter --version`

**Can't connect to backend from app:**
- Make sure backend is running
- Check the `baseUrl` in `auth_service.dart`
- For physical devices, use local IP address

---

## 📁 Project Structure

```
FitMind/
├── backend/              # Node.js + Express API
│   ├── config/          # Database configuration
│   ├── controllers/     # Business logic
│   ├── models/          # MongoDB schemas
│   ├── routes/          # API routes
│   ├── middleware/      # Auth middleware
│   └── server.js        # Entry point
└── lib/                 # Flutter app
    ├── screens/         # UI screens
    └── services/        # API integration
```
