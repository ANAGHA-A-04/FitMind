const mongoose = require('mongoose');

const completionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  level: {
    type: Number,
    required: true,
    default: 1,
  },
  tasksCompleted: {
    type: Number,
    required: true,
  },
  totalTasks: {
    type: Number,
    required: true,
  },
  completionPercentage: {
    type: Number,
    required: true,
    min: 0,
    max: 100,
  },
  taskDetails: {
    type: Array,
    default: [], // Array of { taskName, isCompleted, value (for sliders) }
  },
  wellnessScore: {
    type: Number,
  },
  dietScore: {
    type: Number,
  },
  xpEarned: {
    type: Number,
    default: 0,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Completion', completionSchema);
