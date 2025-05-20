import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'loginFormKey');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _analyticsService = getIt<AnalyticsService>();

  bool _isLoading = false;
  String? _errorMessage;

  final _authService = getIt<AuthService>();
  final _navigationService = getIt<NavigationService>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Récupérez le paramètre de redirection AVANT l'appel asynchrone
    final redirectLocation = _getRedirectLocation(context);

    try {
      await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      await _analyticsService.logLogin(method: 'email');

      if (mounted) {
        _navigationService.navigateTo(context, redirectLocation ?? '/home');
      }
    } catch (e) {
      AppLogger.error('Login error', e);
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Méthode auxiliaire pour obtenir le paramètre de redirection en toute sécurité
  String? _getRedirectLocation(BuildContext context) {
    try {
      return GoRouterState.of(context).uri.queryParameters['redirect'];
    } catch (e) {
      // Si GoRouterState.of(context) échoue, retourner null
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si on peut revenir en arrière
    final canPop = context.canPop();

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Login',
        // Afficher le bouton de retour si on peut revenir en arrière
        showBackButton: canPop,
        // Si on ne peut pas revenir en arrière (c'est-à-dire que l'utilisateur est arrivé directement sur cette page),
        // ajouter un bouton pour aller à la page d'accueil
        leading:
            !canPop
                ? IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () => _navigationService.navigateTo(context, '/home'),
                )
                : null,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FlutterLogo(size: 80),
                const SizedBox(height: 32),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _navigationService.pushRoute(context, '/forgot-password'),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  onPressed: _isLoading ? null : _login,
                  isLoading: _isLoading,
                  text: 'Login',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => _navigationService.pushRoute(context, '/register'),
                      child: const Text('Register'),
                    ),
                  ],
                ),
                if (!canPop) ...[
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => _navigationService.navigateTo(context, '/home'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Home'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
