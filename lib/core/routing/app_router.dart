import 'package:flutter/material.dart';
import 'package:signova/core/routing/routes.dart';
import 'package:signova/features/auth/screens/options_screen.dart';
import 'package:signova/features/auth/screens/sign_in_screen.dart';
import 'package:signova/features/auth/screens/signup_screen.dart';
import 'package:signova/features/onboarding/screens/onboarding_screen.dart';
import 'package:signova/features/splash/views/splash_screen.dart';
import 'package:signova/main_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(builder: (_) => SplashScreen());

      case Routes.onboardingScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case Routes.signUpScreen:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case Routes.signInScreen:
        return MaterialPageRoute(builder: (_) => const SignInScreen());

      case Routes.optionsScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OptionsScreen(
            username: args['username'] as String,
            email: args['email'] as String,
            phone: args['phone'] as String,
            password: args['password'] as String,
          ),
        );

      case Routes.mainScreen:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('No route defined'))),
        );
    }
  }
}
