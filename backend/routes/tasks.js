const express = require('express');
const router = express.Router();
const { completeLevel, getUserStats } = require('../controllers/tasksController');

// POST /api/tasks/complete - Submit task completion
router.post('/complete', completeLevel);

// GET /api/tasks/stats/:userId - Get user progress
router.get('/stats/:userId', getUserStats);

module.exports = router;
