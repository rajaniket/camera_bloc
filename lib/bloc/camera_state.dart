import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../enums/camera_enums.dart';

// Abstract class representing the various states of the camera
abstract class CameraState extends Equatable {
  @override
  List<Object> get props => [];
}

// Camera initial state when it's not yet initialized
class CameraInitial extends CameraState {}

// Camera ready state when it's initialized and ready to use
class CameraReady extends CameraState {
  final bool isRecordingVideo; // Flag indicating if the camera is currently recording a video
  final bool isFrontCamera; // Flag indicating if the front camera is active
  final bool hasRecordingError; // Flag indicating if there was a recording error
  final bool decativateRecordButton; // Flag indicating if the record button should be deactivated
  CameraReady({
    required this.isFrontCamera,
    required this.isRecordingVideo,
    this.hasRecordingError = false,
    this.decativateRecordButton = false,
  });
  @override
  List<Object> get props => [isRecordingVideo, isFrontCamera, hasRecordingError, decativateRecordButton];
}

// Camera recording success state when a recording is successfully completed
class CameraRecordingSuccess extends CameraState {
  final File file; // The recorded video file
  CameraRecordingSuccess({
    required this.file,
  });
  @override
  List<Object> get props => [file];
}

// Camera error state when an error occurs during camera operations
class CameraError extends CameraState {
  final CameraErrorType error; // The type of camera error that occurred
  CameraError({
    required this.error,
  });
  @override
  List<Object> get props => [error];
}
