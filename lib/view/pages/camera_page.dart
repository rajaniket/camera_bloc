import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:camera_bloc/bloc/camera_bloc.dart';
import 'package:camera_bloc/bloc/camera_state.dart';
import 'package:camera_bloc/enums/camera_enums.dart';
import 'package:camera_bloc/camera_utils/screenshot_utils.dart';
import 'package:camera_bloc/view/widgets/animated_bar.dart';
import 'package:camera_bloc/view/pages/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late CameraBloc cameraBloc;
  final GlobalKey screenshotKey = GlobalKey();
  Uint8List? screenshotBytes;
  bool isThisPageVisibe = true;

  @override
  void initState() {
    cameraBloc = BlocProvider.of<CameraBloc>(context);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    // Clean up resources and reset the CameraBloc on page dispose
    cameraBloc.add(CameraReset());
    cameraBloc.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (cameraBloc.getController() == null) return;

    // Handle app lifecycle state changes (e.g., background, foreground)
    if (state == AppLifecycleState.inactive) {
      // Disable the camera when the app is inactive
      cameraBloc.add(CameraDisable());
    }
    if (state == AppLifecycleState.resumed) {
      if (isThisPageVisibe) {
        // Enable the camera when the app is resumed and this page is visible
        cameraBloc.add(CameraEnable());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 54, 53, 53),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: VisibilityDetector(
        key: const Key("my_camera"),
        onVisibilityChanged: _handleVisibilityChanged,
        child: BlocConsumer<CameraBloc, CameraState>(
          listener: _cameraBlocListener,
          builder: _cameraBlocBuilder,
        ),
      ),
    );
  }

  void _cameraBlocListener(BuildContext context, CameraState state) {
    if (state is CameraRecordingSuccess) {
      // Navigate to the VideoPage when video recording is successful
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoPage(videoFile: state.file),
        ),
      );
    } else if (state is CameraReady && state.hasRecordingError) {
      // Show a snackbar when there is a recording error (less than 2 seconds)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black45,
          duration: Duration(milliseconds: 1000),
          content: Text(
            'Please record for at least 2 seconds.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction == 0.0) {
      // Camera page is not visible, disable the camera.
      if (mounted) {
        cameraBloc.add(CameraDisable());
        isThisPageVisibe = false;
      }
    } else {
      // Camera page is visible, enable the camera.
      isThisPageVisibe = true;
      cameraBloc.add(CameraEnable());
    }
  }

  void startRecording() async {
    try {
      takeCameraScreenshot(key: screenshotKey).then((value) {
        screenshotBytes = value;
      });
    } catch (e) {
      rethrow;
    }
    cameraBloc.add(CameraRecordingStart());
  }

  void stopRecording() async {
    cameraBloc.add(CameraRecordingStop());
  }

  Widget _cameraBlocBuilder(BuildContext context, CameraState state) {
    bool disableButtons = !(state is CameraReady && !state.isRecordingVideo);
    //  bool isRecording = state is CameraReady && state.isRecordingVideo;
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              RepaintBoundary(
                key: screenshotKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.linear,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      alwaysIncludeSemantics: true,
                      child: child,
                    );
                  },
                  child: state is CameraReady
                      ? Builder(builder: (context) {
                          var controller = cameraBloc.getController();
                          return Transform.scale(
                            scale: 1 / (controller!.value.aspectRatio * MediaQuery.of(context).size.aspectRatio),
                            child: CameraPreview(controller),
                          );
                        })
                      : state is CameraInitial && screenshotBytes != null
                          ? Container(
                              constraints: const BoxConstraints.expand(),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: MemoryImage(screenshotBytes!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                                child: Container(),
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),
              if (state is CameraError) errorWidget(state),
              Positioned(
                bottom: 30,
                child: SizedBox(
                  width: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IgnorePointer(
                        ignoring: state is! CameraReady || state.decativateRecordButton,
                        child: Opacity(
                          opacity: state is! CameraReady || state.decativateRecordButton ? 0.4 : 1,
                          child: animatedProgressButton(state),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Visibility(
                          visible: !disableButtons,
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.5),
                            radius: 25,
                            child: IconButton(
                              onPressed: () async {
                                try {
                                  screenshotBytes = await takeCameraScreenshot(key: screenshotKey);
                                  if (context.mounted) cameraBloc.add(CameraSwitch());
                                } catch (e) {
                                  //screenshot error
                                }
                              },
                              icon: const Icon(
                                Icons.cameraswitch,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        child: Visibility(
                          visible: !disableButtons,
                          child: StatefulBuilder(builder: (context, localSetState) {
                            return GestureDetector(
                              onTap: () {
                                final List<int> time = [15, 30, 60, 90];
                                int currentIndex = time.indexOf(cameraBloc.recordDurationLimit);
                                localSetState(() {
                                  cameraBloc.setRecordDurationLimit = time[(currentIndex + 1) % time.length];
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.5),
                                radius: 25,
                                child: FittedBox(
                                    child: Text(
                                  "${cameraBloc.recordDurationLimit}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                )),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget animatedProgressButton(CameraState state) {
    bool isRecording = state is CameraReady && state.isRecordingVideo;
    return GestureDetector(
      onTap: () async {
        if (isRecording) {
          stopRecording();
        } else {
          startRecording();
        }
      },
      onLongPress: () {
        startRecording();
      },
      onLongPressEnd: (_) {
        stopRecording();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: isRecording ? 90 : 80,
        width: isRecording ? 90 : 80,
        child: Stack(
          children: [
            AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF978B8B).withOpacity(0.8),
                )),
            ValueListenableBuilder(
                valueListenable: cameraBloc.recordingDuration,
                builder: (context, val, child) {
                  return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: isRecording ? 1100 : 0),
                      tween: Tween<double>(
                        begin: isRecording ? 1 : 0, //val.toDouble(),,
                        end: isRecording ? val.toDouble() + 1 : 0,
                      ),
                      curve: Curves.linear,
                      builder: (context, value, _) {
                        return Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: isRecording ? 90 : 30,
                            width: isRecording ? 90 : 30,
                            child: RecordingProgressIndicator(
                              value: value,
                              maxValue: cameraBloc.recordDurationLimit.toDouble(),
                            ),
                          ),
                        );
                      });
                }),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.linear,
                    height: isRecording ? 25 : 64,
                    width: isRecording ? 25 : 64,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255), //Color(0xffe80415),
                      borderRadius: isRecording ? BorderRadius.circular(6) : BorderRadius.circular(100),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget errorWidget(CameraState state) {
    bool isPermissionError = state is CameraError && state.error == CameraErrorType.permission;
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isPermissionError ? "Please grant access to your camera and microphone to proceed." : "Something went wrong",
              style: const TextStyle(
                color: Color(0xFF959393),
                fontFamily: "Montserrat",
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    onPressed: () async {
                      openAppSettings();
                      Navigator.maybePop(context);
                    },
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(136, 76, 75, 75).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            "Open Setting",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
