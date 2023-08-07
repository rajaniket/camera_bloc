import 'dart:io';
import 'package:camera/camera.dart';

class CameraUtils {
  /// Returns a CameraController with the specified configuration.
  Future<CameraController> getCameraController({
    ResolutionPreset resolutionPreset = ResolutionPreset.high,
    required CameraLensDirection lensDirection,
  }) async {
    // Retrieve the list of available cameras on the device
    final cameras = await availableCameras();

    // Find the camera that matches the specified lens direction
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == lensDirection,
      orElse: () => cameras.first, // If not found, default to the first camera
    );

    // Create a CameraController instance with the selected camera and configuration
    return CameraController(
      camera,
      resolutionPreset,
      imageFormatGroup: Platform.isIOS ? ImageFormatGroup.yuv420 : null, // iOS-specific configuration
    );
  }
}
