import 'package:camera/camera.dart';
import 'package:camera_bloc/bloc/camera_bloc.dart';
import 'package:camera_bloc/bloc/camera_state.dart';
import 'package:camera_bloc/utils/camera_utils.dart';
import 'package:camera_bloc/utils/permission_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCameraUtils extends Mock implements CameraUtils {}

class MockPermissionUtils extends Mock implements PermissionUtils {}

class MockCameraController extends Mock implements CameraController {}

void main() {
  group("CameraBloc", () {
    late MockPermissionUtils permissionUtils;
    late MockCameraUtils cameraUtils;
    late CameraBloc cameraBloc;
    late MockCameraController cameraController;

    //Registers a function to be run before tests.
    setUp(() async {
      permissionUtils = MockPermissionUtils();
      cameraUtils = MockCameraUtils();
      cameraController = MockCameraController();
      // mockVideoFile = MockFile();
      cameraBloc = CameraBloc(
        permissionUtils: permissionUtils,
        cameraUtils: cameraUtils,
      );

      // registerFallbackValue(CameraLensDirection.back);
      registerFallbackValue(CameraLensDirection.back);

      // Default responses
      when(() => cameraController.initialize()).thenAnswer((_) => Future.value());
      when(() => cameraUtils.getCameraController(lensDirection: any(named: 'lensDirection'))).thenAnswer((_) => Future.value(cameraController));
      when(() => permissionUtils.askForPermission()).thenAnswer((_) => Future.value(true));
      when(() => permissionUtils.getCameraAndMicrophonePermissionStatus()).thenAnswer((_) => Future.value(true));
    });

    //Registers a function to be run after tests.
    tearDown(() {
      cameraBloc.close();
    });

    CameraBloc createCameraBloc() {
      return CameraBloc(
        permissionUtils: permissionUtils,
        cameraUtils: cameraUtils,
      );
    }

    test("intial state", () {
      expect(cameraBloc.state, CameraInitial());
    });

    blocTest<CameraBloc, CameraState>(
      'emits CameraReady when CameraInitialize event is added',
      build: createCameraBloc,
      act: (bloc) => bloc.add(const CameraInitialize(recordingLimit: 15)),
      expect: () => [
        CameraReady(isRecordingVideo: false),
      ],
    );
  });
}
