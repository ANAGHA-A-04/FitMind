import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class StepService {

  StreamSubscription<StepCount>? _stepSubscription;

  Future<void> startStepCounter(Function(int) onStepUpdate) async {

    // Request permission
    var status = await Permission.activityRecognition.request();

    if (status.isGranted) {

      _stepSubscription = Pedometer.stepCountStream.listen(
            (StepCount event) {
              print("sensor steps: ${event.steps}");
          onStepUpdate(event.steps);
        },
        onError: (error) {
          print("Step Counter Error: $error");
        },
      );

    } else {
      print("Activity recognition permission denied");
    }

  }

  void stopStepCounter() {
    _stepSubscription?.cancel();
  }
}