# FitMind

**Calm Mind. Active Body.**

A fitness and wellness mobile application built with Flutter and Node.js.

## 🎯 Features

- ✅ User Authentication (Register/Login)
- ✅ JWT Token-based Security
- ✅ Fitness Goal Tracking (Lose Weight, Gain Muscle, Maintain Fitness)
- ✅ User Profile Management
- 🚧 AI Chatbot Integration (Coming Soon)
- 🚧 Workout Tracking
- 🚧 Nutrition Planning

## 🛠️ Tech Stack

**Frontend:**
- Flutter 3.11+
- Dart
- HTTP package for API calls
- SharedPreferences for local storage

**Backend:**
- Node.js + Express
- MongoDB (Atlas)
- JWT Authentication
- Bcrypt for password hashing

## 📋 Prerequisites

- Node.js v18+
- Flutter SDK 3.11+
- MongoDB Atlas account

## 🚀 Quick Start

See [SETUP.md](SETUP.md) for detailed setup instructions.

**Quick commands:**
```bash
# Backend
cd backend
npm install
cp .env.example .env
# Edit .env with your MongoDB credentials
npm start

# Frontend (in new terminal)
cd ..
flutter pub get
flutter run
```

## 📂 Project Structure

```
FitMind/
├── backend/              # Node.js REST API
├── lib/                  # Flutter application
│   ├── screens/         # UI screens
│   └── services/        # API integration
└── fitmind_chatbot/     # AI chatbot (Python)
```

## 🧪 Testing

Backend API tested and working with Postman. All endpoints functional:
- ✅ User Registration
- ✅ User Login
- ✅ Protected Routes (Profile)

## 📱 Screenshots

Coming soon...

## 👥 Contributing

1. Clone the repo
2. Follow setup instructions in [SETUP.md](SETUP.md)
3. Create a feature branch
4. Make your changes
5. Submit a pull request

## 📄 License

This project is for educational purposes.
