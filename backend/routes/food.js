const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { analyzeFood } = require('../controllers/foodController');

// Configure multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/'); // Save uploaded files to uploads directory
    },
    filename: (req, file, cb) => {
        // Generate unique filename
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({
    storage: storage,
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB limit
    },
    fileFilter: (req, file, cb) => {
        // Check if file is an image by mimetype or extension
        const allowedMimes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
        const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];

        const fileExt = path.extname(file.originalname).toLowerCase();

        if (allowedMimes.includes(file.mimetype) || allowedExtensions.includes(fileExt)) {
            cb(null, true);
        } else {
            cb(new Error(`Only image files are allowed! Got: ${file.mimetype}, ext: ${fileExt}`), false);
        }
    }
});

// POST /api/food/analyze - Analyze food image
router.post('/analyze', upload.single('image'), analyzeFood);

module.exports = router;