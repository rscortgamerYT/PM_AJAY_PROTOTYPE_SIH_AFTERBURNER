import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/router/app_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.session != null) {
        // Get role from user metadata
        final userMetadata = response.user!.userMetadata;
        final role = userMetadata?['role'] as String?;

        if (!mounted) return;

        if (role == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('User role not found. Please contact administrator.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          await Supabase.instance.client.auth.signOut();
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid user role: $role'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            await Supabase.instance.client.auth.signOut();
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _bypassLogin(String role) {
    Navigator.of(context).pushReplacementNamed(
      _getRouteForRole(role),
    );
  }

  String _getRouteForRole(String role) {
    switch (role) {
      case 'centre':
        return AppRouter.centreDashboard;
      case 'state':
        return AppRouter.stateDashboard;
      case 'agency':
        return AppRouter.agencyDashboard;
      case 'overwatch':
        return AppRouter.newOverwatchDashboard;
      case 'public':
        return AppRouter.publicDashboard;
      default:
        return AppRouter.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'PM-AJAY Platform',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Agency Mapping & Monitoring',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 48),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign In',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Sign In'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Don\'t have an account? '),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacementNamed(AppRouter.register);
                                },
                                child: const Text('Register'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'Quick Access',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _BypassButton(
                                label: 'Centre',
                                icon: Icons.account_balance,
                                color: Colors.blue,
                                onPressed: () => _bypassLogin('centre'),
                              ),
                              _BypassButton(
                                label: 'State',
                                icon: Icons.location_city,
                                color: Colors.green,
                                onPressed: () => _bypassLogin('state'),
                              ),
                              _BypassButton(
                                label: 'Agency',
                                icon: Icons.business,
                                color: Colors.purple,
                                onPressed: () => _bypassLogin('agency'),
                              ),
                              _BypassButton(
                                label: 'Overwatch',
                                icon: Icons.visibility,
                                color: Colors.red,
                                onPressed: () => _bypassLogin('overwatch'),
                              ),
                              _BypassButton(
                                label: 'Public',
                                icon: Icons.public,
                                color: Colors.teal,
                                onPressed: () => _bypassLogin('public'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BypassButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _BypassButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}