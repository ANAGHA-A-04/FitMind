const Completion = require('../models/completion');
const UserStats = require('../models/userStats');
const axios = require('axios');

// Complete tasks and generate next level
exports.completeLevel = async (req, res) => {
  try {
    const { userId, level, tasks, wellnessScore, dietScore } = req.body;

    if (!userId || level === undefined || !tasks || tasks.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: userId, level, tasks',
      });
    }

    // Calculate completion data
    let tasksCompleted = 0;
    let taskDetails = [];

    tasks.forEach((task) => {
      let isCompleted = false;
      let value = 0;
      let completionFraction = 0;

      if (task.isQuantifiable) {
        // For sliders: consider partial completion
        completionFraction = task.targetValue > 0 ? Math.min(task.actualValue / task.targetValue, 1) : 0;
        isCompleted = completionFraction === 1;
        value = task.actualValue;
      } else {
        // For checkboxes: check if marked done
        isCompleted = task.isCompleted;
        completionFraction = isCompleted ? 1 : 0;
      }

      tasksCompleted += completionFraction;

      taskDetails.push({
        name: task.name,
        isCompleted,
        type: task.isQuantifiable ? 'quantifiable' : 'qualitative',
        value: value || (isCompleted ? 1 : 0),
      });
    });

    const totalTasks = tasks.length;
    const completionPercentage = Math.round((tasksCompleted / totalTasks) * 100);

    // Calculate XP: base 50, bonus for completion percentage
    const xpEarned = Math.round(50 + (completionPercentage * 0.5));

    // Save completion record
    const completion = new Completion({
      userId,
      level,
      tasksCompleted,
      totalTasks,
      completionPercentage,
      taskDetails,
      wellnessScore: wellnessScore || 0,
      dietScore: dietScore || 0,
      xpEarned,
    });

    await completion.save();

    // Update user stats
    let userStats = await UserStats.findOne({ userId });

    if (!userStats) {
      userStats = new UserStats({
        userId,
        currentLevel: level,
        totalXP: xpEarned,
        averageCompletionPercentage: completionPercentage,
        totalCompletions: 1,
        lastCompletionDate: new Date(),
      });
    } else {
      // Update existing stats
      userStats.totalCompletions += 1;
      userStats.totalXP += xpEarned;
      userStats.averageCompletionPercentage =
        (userStats.averageCompletionPercentage + completionPercentage) / 2;
      userStats.lastCompletionDate = new Date();

      // Unlock next level if completion >= 60%
      if (completionPercentage >= 60 && level >= userStats.currentLevel) {
        userStats.currentLevel = level + 1;
      }
    }

    await userStats.save();

    // ==========================
    // Call Adaptive Engine
    // ==========================

    let adaptiveResponse = null;
    let nextLevelTasks = [];

    try {
      const adaptiveUrl = process.env.ADAPTIVE_ENGINE_URL || 'http://192.168.43.12:5004';

      adaptiveResponse = await axios.post(`${adaptiveUrl}/generate_tasks`, {
        userId,
        previousLevel: level,
        previousCompletion: completionPercentage,
        wellnessScore: wellnessScore || 50,
        dietScore: dietScore || 50,
      });

      nextLevelTasks = adaptiveResponse.data.tasks || [];

      console.log(`✅ Adaptive engine generated ${nextLevelTasks.length} tasks for level ${level + 1}`);
    } catch (adaptiveError) {
      console.error('⚠️ Adaptive engine error:', adaptiveError.message);
      // Continue without adaptive tasks (fallback)
    }

    res.status(200).json({
      success: true,
      message: 'Level completed successfully',
      completion: {
        level,
        tasksCompleted,
        totalTasks,
        completionPercentage,
        xpEarned,
      },
      userStats: {
        currentLevel: userStats.currentLevel,
        totalXP: userStats.totalXP,
        levelUnlocked: completionPercentage >= 60,
      },
      nextLevel: level + 1,
      nextLevelTasks: nextLevelTasks,
    });
  } catch (error) {
    console.error('Error completing level:', error);
    res.status(500).json({
      success: false,
      message: 'Error completing level',
      error: error.message,
    });
  }
};

// Get user stats
exports.getUserStats = async (req, res) => {
  try {
    const { userId } = req.params;

    const userStats = await UserStats.findOne({ userId });

    if (!userStats) {
      return res.status(404).json({
        success: false,
        message: 'User stats not found',
      });
    }

    // Fetch all completions for this user to get completedLevels
    const completions = await Completion.find({ userId }).sort({ level: 1 });
    const completedLevels = completions.map(c => String(c.level));

    res.status(200).json({
      success: true,
      currentLevel: userStats.currentLevel,
      totalXP: userStats.totalXP,
      averageCompletionPercentage: userStats.averageCompletionPercentage,
      totalCompletions: userStats.totalCompletions,
      lastCompletionDate: userStats.lastCompletionDate,
      completedLevels: completedLevels,
      stats: userStats,
    });
  } catch (error) {
    console.error('Error fetching user stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching user stats',
      error: error.message,
    });
  }
};
