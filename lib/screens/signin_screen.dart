import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/custom_textformfield.dart';
import '../widgets/custom_inkwell_button.dart';
import '../constants.dart';
import '../services/api_exception.dart';
import '../services/user_service.dart';
import '../session/session.dart';
import '../widgets/custom_dialogs.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserService _userService = UserService();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _userService.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final user = await _userService.login(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );
      Session.authenticatedUser = user;
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on ApiException catch (error) {
      if (!mounted) return;
      customDialog(context, title: 'Login Failed', content: error.message);
    } catch (error) {
      if (!mounted) return;
      customDialog(context, title: 'Login Failed', content: error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: ScreenUtil().screenWidth,
                  height: ScreenUtil().setHeight(40),
                  color: FB_DARK_PRIMARY,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(25),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/pongkan_logo_nobg.png',
                        height: ScreenUtil().setHeight(150),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(10)),
                      CustomTextformfield(
                        height: ScreenUtil().setHeight(10),
                        width: ScreenUtil().setWidth(10),
                        controller: usernameController,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter your username' : null,
                        onSaved: null,
                        fontSize: ScreenUtil().setSp(15),
                        fontColor: FB_DARK_PRIMARY,
                        hintTextSize: ScreenUtil().setSp(15),
                        hintText: 'Username',
                      ),
                      SizedBox(height: ScreenUtil().setHeight(10)),
                      CustomTextformfield(
                        height: ScreenUtil().setHeight(10),
                        width: ScreenUtil().setWidth(10),
                        controller: passwordController,
                        isObscure: _obscurePassword,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter your password' : null,
                        onSaved: null,
                        fontSize: ScreenUtil().setSp(15),
                        fontColor: FB_DARK_PRIMARY,
                        hintTextSize: ScreenUtil().setSp(15),
                        hintText: 'Password',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: FB_DARK_PRIMARY,
                            size: ScreenUtil().setSp(22),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(50)),
                      CustomInkwellButton(
                        onTap: _isSubmitting ? null : _signIn,
                        height: ScreenUtil().setHeight(40),
                        width: ScreenUtil().screenWidth,
                        buttonName: _isSubmitting ? 'Signing in...' : 'Login',
                        fontSize: ScreenUtil().setSp(15),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: ScreenUtil().screenWidth,
                  height: ScreenUtil().setHeight(40),
                  color: FB_DARK_PRIMARY,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'You do not have an account? ',
                        style: TextStyle(
                          color: Colors.grey.shade200,
                          fontSize: ScreenUtil().setSp(15),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => customDialog(
                          context,
                          title: 'DummyJSON Login',
                          content:
                              'Enter any non-empty username and password to continue.',
                        ),
                        child: Text(
                          'Register here',
                          style: TextStyle(
                            color: FB_LIGHT_PRIMARY,
                            fontSize: ScreenUtil().setSp(15),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
