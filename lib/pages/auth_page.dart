import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/providers/auth_provider.dart';
import 'package:yap_zone/providers/cloud_storage_provider.dart';
import 'package:yap_zone/providers/database_provider.dart';
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
    final databaseService = ref.read(databaseServiceProvider);
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
          return;
        }
        await databaseService.updateUserActivity(result.credential!.user!.uid);

        _showSnackBar(
          icon: const Icon(Icons.check_circle),
          text: Text(
            'Welcome back, ${result.credential!.user!.email}!',
            softWrap: true,
            overflow: TextOverflow.visible,
            textHeightBehavior: TextHeightBehavior(),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        );
      } else {
        if (_pickedImage == null) {
          _showSnackBar(
            icon: const Icon(Icons.error),
            text: const Text(
              'Please select an image',
              softWrap: true,
              overflow: TextOverflow.visible,
              textHeightBehavior: TextHeightBehavior(),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          );
          return;
        }
        // Call sign up method
        final result = await authService.signUp(
          email: _emailAddress,
          username: _username,
          password: _password,
        );

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
          return;
        }

        final userImageUrl = await ref
            .read(cloudStorageServiceProvider)
            .uploadUserImage(result.credential!.user!.uid, _pickedImage!);

        await databaseService.saveUserData(
          result.credential!.user!.uid,
          _emailAddress,
          _username,
          userImageUrl,
        );

        _showSnackBar(
          icon: const Icon(Icons.check_circle),
          text: Text(
            'Welcome, ${result.credential!.user!.email}!',
            softWrap: true,
            overflow: TextOverflow.visible,
            textHeightBehavior: TextHeightBehavior(),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      _showSnackBar(
        icon: const Icon(Icons.error),
        text: Text(
          e.toString(),
          softWrap: true,
          overflow: TextOverflow.visible,
          textHeightBehavior: TextHeightBehavior(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        ref.read(navigationServiceProvider).popUntilFirst();
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
                  UserImagePicker(
                    onPickImage: (image) =>
                        setState(() => _pickedImage = image),
                  ),
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
                    onSaved: (value) => setState(() => _username = value ?? ''),
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
                  onSaved: (value) =>
                      setState(() => _emailAddress = value ?? ''),
                ),
                InputFormField(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  isPasswordField: true,
                  onChanged: (value) => setState(() => _password = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (value) => setState(() => _password = value ?? ''),
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
                    onSaved: (value) =>
                        setState(() => _confirmPassword = value ?? ''),
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
                            navigation.pushAndRemoveUntilFirst(AuthPage(authMode: AuthMode.signUp));
                          } else {
                            navigation.pushAndRemoveUntilFirst(AuthPage(authMode: AuthMode.signIn));
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
