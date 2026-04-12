const { spawn } = require('child_process');
const path = require('path');

const analyzeFood = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: 'No image file provided'
            });
        }

        const imagePath = req.file.path;

        // Call Python script for food analysis
        const pythonProcess = spawn('python', [
            path.join(__dirname, '../../predict_food_api.py'),
            '--image', path.resolve(req.file.path),  // Use absolute path
            '--json'
        ], {
            cwd: path.join(__dirname, '../..'), // Set working directory to project root
            stdio: ['pipe', 'pipe', 'pipe']
        });

        let output = '';
        let errorOutput = '';

        pythonProcess.stdout.on('data', (data) => {
            output += data.toString();
        });

        pythonProcess.stderr.on('data', (data) => {
            errorOutput += data.toString();
        });

        pythonProcess.on('close', (code) => {
            if (code !== 0) {
                console.error('Python script error:', errorOutput);
                return res.status(500).json({
                    success: false,
                    message: 'Failed to analyze food image',
                    error: errorOutput
                });
            }

            try {
                // Parse the Python script JSON output
                const result = JSON.parse(output.trim());

                if (result.error) {
                    return res.status(400).json({
                        success: false,
                        message: result.error
                    });
                }

                res.json({
                    success: true,
                    food: result.food,
                    confidence: result.confidence,
                    calories: result.calories,
                    protein: result.protein,
                    carbs: result.carbs,
                    fat: result.fat,
                    fiber: result.fiber
                });
            } catch (parseError) {
                console.error('Output parsing error:', parseError);
                console.error('Raw output:', output);
                res.status(500).json({
                    success: false,
                    message: 'Failed to parse analysis results'
                });
            }
        });

        pythonProcess.on('error', (error) => {
            console.error('Process error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to start food analysis'
            });
        });

    } catch (error) {
        console.error('Food analysis error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

// Helper function to parse Python script output (deprecated - now using JSON)
function parsePythonOutput(output) {
    // This is a simplified parser - you may need to adjust based on your Python script output
    const lines = output.split('\n');
    let result = {
        food: 'Unknown',
        confidence: 0,
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        fiber: 0
    };

    for (const line of lines) {
        if (line.includes('Predicted:')) {
            const match = line.match(/Predicted:\s*([^()]+)\s*\(([^)]+)\)/);
            if (match) {
                result.food = match[1].trim();
                result.confidence = parseFloat(match[2]);
            }
        } else if (line.includes('Calories:')) {
            result.calories = parseFloat(line.split(':')[1].trim().split(' ')[0]);
        } else if (line.includes('Protein:')) {
            result.protein = parseFloat(line.split(':')[1].trim().split(' ')[0]);
        } else if (line.includes('Carbs:')) {
            result.carbs = parseFloat(line.split(':')[1].trim().split(' ')[0]);
        } else if (line.includes('Fat:')) {
            result.fat = parseFloat(line.split(':')[1].trim().split(' ')[0]);
        } else if (line.includes('Fiber:')) {
            result.fiber = parseFloat(line.split(':')[1].trim().split(' ')[0]);
        }
    }

    return result;
}

module.exports = {
    analyzeFood
};