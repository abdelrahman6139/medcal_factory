import 'package:go_router/go_router.dart';
import 'package:pharma_app/features/auth/presentation/screens/onboarding_screen.dart';


final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: '/',builder:  (_,__) {
        return OnboardingScreen();

      })

    ]
);