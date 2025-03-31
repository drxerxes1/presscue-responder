import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_icons.dart';
import 'package:presscue_patroller/core/constants/app_text.dart';
import 'package:presscue_patroller/core/database/boxes.dart';
import 'package:presscue_patroller/core/database/user.dart';
import 'package:presscue_patroller/core/navigation/app_routes.dart';
import 'package:presscue_patroller/core/services/device_info.dart';
import 'package:presscue_patroller/core/utils/widgets.dart/custom_message.dart';
import 'package:presscue_patroller/features/auth/login_data_source.dart';

class LoginPasswordPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  const LoginPasswordPage({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  ConsumerState<LoginPasswordPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends ConsumerState<LoginPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(mediaQuery.size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildWelcomeText(),
            SizedBox(height: mediaQuery.size.height * 0.1),
            _buildPasswordTextField(),
            Spacer(),
            _buildSubmitButton(),
            SizedBox(height: mediaQuery.size.height * 0.02),
            _buildForgotPassword(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Text(
      'Enter your password',
      style: AppText.header2,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintStyle: TextStyle(color: AppColors.muted),
        hintText: 'Enter your password',
        border: _buildOutlineInputBorder(AppColors.textField),
        filled: true,
        fillColor: AppColors.textField,
        enabledBorder: _buildOutlineInputBorder(AppColors.textField),
        focusedBorder: _buildOutlineInputBorder(AppColors.textField),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.muted,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
            });
          },
        ),
      ),
    );
  }

  bool _isLoading = false;

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null // Disable button when loading
            : () async {
                if (_passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please Enter Password')),
                  );
                  return;
                }

                setState(() => _isLoading = true); // Start loading

                final deviceInfo = await DeviceInfo.getPhoneInfo();
                final deviceModel = deviceInfo['model'];
                String password = _passwordController.text;

                Map<String, dynamic> jsonData = {
                  'phone': widget.phoneNumber,
                  'password': password,
                  'device_name': deviceModel,
                };

                await _loginUser(jsonData, context);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(
                'Continue',
                style: AppText.subtitle1,
              ),
      ),
    );
  }

  Future<void> _loginUser(
      Map<String, dynamic> jsonData, BuildContext context) async {
    setState(() => _isLoading = true); // Set loading before request starts

    final dio = Dio();
    final loginDataSource = LoginDataSourceImpl(dio);

    try {
      final response = await loginDataSource.loginUser(jsonData);
      print("[LOG] Response Data: ${response.data}");

      if (response.statusCode == 200) {
        var userData = response.data;

        if (userData == null || userData['user'] == null) {
          print("Invalid response format: $userData");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unexpected response from server')),
          );
          return;
        }

        setState(() => _isLoading = false);

        final String user_id = userData['user']['id'].toString();
        final String name = userData['user']['name'];
        final String role_id = userData['user']['role']['id'].toString();
        final String role_title = userData['user']['role']['title'];
        final String sector = userData['user']['sector']['id'].toString();
        final String token = userData['token'].toString();
        final deviceInfo = await DeviceInfo.getPhoneInfo();
        final deviceModel = deviceInfo['model'].toString();

        print('token: $token');

        boxUsers.put(
            1,
            User(
                userId: user_id,
                name: name,
                role: role_title,
                roleId: role_id,
                sector: sector,
                token: token,
                phone: widget.phoneNumber,
                device: deviceModel));
        print(boxUsers.get(1).toString());

        CustomToastMessage(
          message: 'Welcome Back! $name',
          iconPath: AppIcons.icPresscueSOS,
          backgroundColor: AppColors.accent,
          iconBackgroundColor: AppColors.primaryColor,
        ).show(context);
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.main, (route) => false);
      } else if (response.data != null && response.data['errors'] != null) {
        setState(() => _isLoading = false);
        String errorMessage =
            response.data['errors']['phone'] ?? "Login failed";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print('Error during user login: $e');

      if (e is DioException) {
        print("DioException: ${e.message}");
        print("Dio Response: ${e.response?.data}");

        if (e.response?.data != null && e.response?.data['errors'] != null) {
          String errorMessage =
              e.response?.data['errors']['phone'] ?? "Unknown error";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to login due to a network error')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to login due to an unknown error')),
        );
      }
    } finally {
      setState(() => _isLoading = false); // Ensure loading state is reset
    }
  }
}

Widget _buildForgotPassword() {
  return TextButton(
    onPressed: () {},
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryColor,
    ),
    child: const Text(
      'Forgot Password?',
      style: AppText.body2,
    ),
  );
}

OutlineInputBorder _buildOutlineInputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(20.0),
    borderSide: BorderSide(color: color),
  );
}
