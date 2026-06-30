import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:signova/core/data/user.dart';
import 'package:signova/core/routing/app_router.dart';
import 'package:signova/core/routing/routes.dart';
import 'package:sizer/sizer.dart';

late List<CameraDescription> cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await User().load();
  runApp(MyApp(appRouter: AppRouter()));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => SafeArea(
        top: false,
        child: MaterialApp(
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          title: 'Signova',
          initialRoute: Routes.splashScreen,
          theme: ThemeData(fontFamily: 'inter'),
          onGenerateRoute: appRouter.generateRoute,
        ),
      ),
    );
  }
}

class UnityScreen extends StatelessWidget {
  const UnityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: EmbedUnity(
              onMessageFromUnity: (String message) {
                debugPrint("Message from Unity: $message");
              },
            ),
          ),

          // ElevatedButton(
          //   onPressed: () {
          //     sendToUnity(
          //       "MyGameObject", // اسم الـ GameObject في Unity
          //       "SetRotationSpeed", // اسم الفنكشن في Unity script
          //       "42", // القيمة اللي بتتبعت
          //     );
          //   },
          //   child: const Text("Set rotation speed"),
          // ),
        ],
      ),
    );
  }
}
