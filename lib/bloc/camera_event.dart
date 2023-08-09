// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'camera_bloc.dart';

// Abstract class representing camera-related events
abstract class CameraEvent extends Equatable {
  const CameraEvent();
  @override
  List<Object> get props => [];
}

// Event to initialize the camera
class CameraInitialize extends CameraEvent {
  /// duration in second
  final int recordingLimit;
  const CameraInitialize({
    this.recordingLimit = 15,
  });
}

// Event to switch between front and back cameras
class CameraSwitch extends CameraEvent {}

// Event to start video recording
class CameraRecordingStart extends CameraEvent {}

// Event to stop video recording
class CameraRecordingStop extends CameraEvent {}

// Event to disable the camera when not in use
class CameraDisable extends CameraEvent {}

// Event to enable the camera when in use
class CameraEnable extends CameraEvent {}

// Event to reset the camera BLoC to its initial state
class CameraReset extends CameraEvent {}
