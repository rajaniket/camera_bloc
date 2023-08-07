import 'package:camera_bloc/bloc/camera_bloc.dart';
import 'package:camera_bloc/utils/camera_utils.dart';
import 'package:camera_bloc/utils/permission_utils.dart';
import 'package:camera_bloc/view/pages/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, appBarTheme: const AppBarTheme(elevation: 20)),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Home"),
          centerTitle: true,
        ),
        body: Center(
            child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) {
                    return CameraBloc(
                      cameraUtils: CameraUtils(),
                      permissionUtils: PermissionUtils(),
                    )..add(const CameraInitialize(recordingLimit: 15));
                  },
                  child: const CameraPage(),
                ),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Camera 📷",
              style: TextStyle(fontSize: 25),
            ),
          ),
        )));
  }
}
