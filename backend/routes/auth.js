const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { register, login, getMe } = require('../controllers/authController');
const { protect } = require('../middleware/auth');

// Validation middleware for registration
const registerValidation = [
    body('name')
        .trim()
        .notEmpty()
        .withMessage('Name is required')
        .isLength({ min: 2 })
        .withMessage('Name must be at least 2 characters'),
    
    body('email')
        .trim()
        .notEmpty()
        .withMessage('Email is required')
        .isEmail()
        .withMessage('Please provide a valid email')
        .normalizeEmail(),
    
    body('password')
        .notEmpty()
        .withMessage('Password is required')
        .isLength({ min: 6 })
        .withMessage('Password must be at least 6 characters'),
    
    body('weight')
        .notEmpty()
        .withMessage('Weight is required')
        .isNumeric()
        .withMessage('Weight must be a number')
        .custom((value) => value > 0)
        .withMessage('Weight must be positive'),
    
    body('height')
        .notEmpty()
        .withMessage('Height is required')
        .isNumeric()
        .withMessage('Height must be a number')
        .custom((value) => value > 0)
        .withMessage('Height must be positive'),
    
    body('dateOfBirth')
        .notEmpty()
        .withMessage('Date of birth is required')
        .isISO8601()
        .withMessage('Please provide a valid date'),
    
    body('goal')
        .notEmpty()
        .withMessage('Goal is required')
        .isIn(['lose weight', 'gain muscle', 'maintain fitness'])
        .withMessage('Invalid goal selection')
];

// Validation middleware for login
const loginValidation = [
    body('email')
        .trim()
        .notEmpty()
        .withMessage('Email is required')
        .isEmail()
        .withMessage('Please provide a valid email')
        .normalizeEmail(),
    
    body('password')
        .notEmpty()
        .withMessage('Password is required')
];

// Routes
router.post('/register', registerValidation, register);
router.post('/login', loginValidation, login);
router.get('/me', protect, getMe);

module.exports = router;
