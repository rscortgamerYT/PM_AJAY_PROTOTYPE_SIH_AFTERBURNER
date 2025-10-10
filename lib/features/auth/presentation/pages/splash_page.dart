import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/router/app_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final session = Supabase.instance.client.auth.currentSession;
    
    if (session != null) {
      // Get role from user metadata
      final userMetadata = session.user.userMetadata;
      final role = userMetadata?['role'] as String?;
      
      if (!mounted) return;
      
      if (role == null) {
        // No role found, sign out and redirect to login
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRouter.login);
        }
        return;
      }
      
      switch (role) {
        case 'centre':
          Navigator.of(context).pushReplacementNamed(AppRouter.centreDashboard);
          break;
        case 'state':
          Navigator.of(context).pushReplacementNamed(AppRouter.stateDashboard);
          break;
        case 'agency':
          Navigator.of(context).pushReplacementNamed(AppRouter.agencyDashboard);
          break;
        case 'overwatch':
          Navigator.of(context).pushReplacementNamed(AppRouter.overwatchDashboard);
          break;
        case 'public':
          Navigator.of(context).pushReplacementNamed(AppRouter.publicDashboard);
          break;
        default:
          // Invalid role, sign out and redirect to login
          await Supabase.instance.client.auth.signOut();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRouter.login);
          }
      }
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'PM-AJAY',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Agency Mapping Platform',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              ),
              const SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}