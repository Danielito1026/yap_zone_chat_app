import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/providers/auth_provider.dart';
import 'package:yap_zone/providers/navigator_provider.dart';
import 'package:yap_zone/widgets/app_snackbar.dart';
import 'package:yap_zone/widgets/hero_logo.dart';
import 'package:yap_zone/widgets/inputs/input_form_field.dart';
import 'package:yap_zone/widgets/inputs/user_image_picker.dart';

enum AuthMode { signIn, signUp }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key, required this.authMode});

  final AuthMode authMode;

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  late double _deviceWidth;
  late double _deviceHeight;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _username = '';
  String _emailAddress = '';
  String _password = '';
  String _confirmPassword = '';
  File? _pickedImage;

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState?.save();
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);

    try {
      if (widget.authMode == AuthMode.signIn) {
        // Call sign in method
        final result = await authService.signIn(_emailAddress, _password);
        if (result.error != null) {
          _showSnackBar(
            icon: const Icon(Icons.error),
            text: Text(
              result.error!,
              softWrap: true,
              overflow: TextOverflow.visible,
              textHeightBehavior: TextHeightBehavior(),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          );
        }
      } else {
        // Call sign up method
        // await authService.signUp(_emailAddress, _password);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar({
    required Icon icon,
    required Text text,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      AppSnackbar.iconSnackbar(
        context,
        icon: icon,
        text: text,
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    final navigation = ref.read(navigationServiceProvider);

    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.1,
            vertical: _deviceHeight * 0.02,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  _deviceHeight -
                  (_deviceHeight * 0.04), // Account for vertical padding
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                HeroLogo(),
                const SizedBox(height: 32),
                if (widget.authMode == AuthMode.signUp) ...[
                  UserImagePicker(onPickImage: (image) => _pickedImage = image),
                  InputFormField(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      if (value.length < 4) {
                        return 'Username must be at least 4 characters';
                      }
                      return null;
                    },
                    onSaved: (value) => _username = value ?? '',
                  ),
                ],
                InputFormField(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) => _emailAddress = value ?? '',
                ),
                InputFormField(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  isPasswordField: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value ?? '',
                ),
                if (widget.authMode == AuthMode.signUp)
                  InputFormField(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    isPasswordField: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _password) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onSaved: (value) => _confirmPassword = value ?? '',
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: Text(
                    _isLoading
                        ? 'Loading...'
                        : widget.authMode == AuthMode.signIn
                        ? 'Sign In'
                        : 'Sign Up',
                  ),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (widget.authMode == AuthMode.signIn) {
                            navigation.navigateToPage(
                              AuthPage(authMode: AuthMode.signUp),
                            );
                          } else {
                            navigation.navigateToPage(
                              AuthPage(authMode: AuthMode.signIn),
                            );
                          }
                        },
                  child: Text(
                    widget.authMode == AuthMode.signIn
                        ? 'Don\'t have an account? Sign Up'
                        : 'Already have an account? Sign In',
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
