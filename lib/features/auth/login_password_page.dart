import 'dart:convert'; // Import for JSON conversion
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_text.dart';
import 'package:presscue_patroller/core/database/boxes.dart';
import 'package:presscue_patroller/core/database/user.dart';
import 'package:presscue_patroller/core/navigation/app_routes.dart';
import 'package:presscue_patroller/core/services/device_info.dart';
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
      controller: _passwordController, // Use the controller to get the password
      obscureText: true,
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
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () async {
          if (_passwordController.text == '') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please Enter Password'),
              ),
            );
          } else {
            final deviceInfo = await DeviceInfo.getPhoneInfo();
            final deviceModel = deviceInfo['model'];
            String password = _passwordController.text;

            Map<String, dynamic> jsonData = {
              'phone': widget.phoneNumber,
              'password': password,
              'device_name': deviceModel,
            };

            String jsonString = json.encode(jsonData);
            print(jsonString);

            _loginUser(jsonData, context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          'Continue',
          style: AppText.subtitle1,
        ),
      ),
    );
  }

  Future<void> _loginUser(
      Map<String, dynamic> jsonData, BuildContext context) async {
    final dio = Dio(); // Create an instance of Dio
    final loginDataSource = LoginDataSourceImpl(dio);

    try {
      final response = await loginDataSource.loginUser(jsonData);

      // If we reach here, it means the response was successful
      print('Login successful: ${response.data}');

      final userData = response.data['user'];
      final String name = userData['name'];
      final String role = userData['role'];
      final String sector = response.data['sector'];
      final deviceInfo = await DeviceInfo.getPhoneInfo();
      final deviceModel = deviceInfo['model'].toString();

      boxUsers.put(
          1,
          User(
              name: name,
              role: role,
              sector: sector,
              phone: widget.phoneNumber,
              device: deviceModel));
      print(boxUsers.get(1).toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
    } catch (e) {
      // Log the error for debugging
      print('Error during user login: $e');

      if (e is DioException) {
        // Access the response and error message
        final response = e.response;

        // Log the response data for debugging
        print('DioError response: ${response?.data}');

        if (response != null && response.data != null) {
          // Check if the errors map exists
          if (response.data['errors'] != null &&
              response.data['errors']['phone'] != null) {
            // Extract the error message for phone
            String errorMessage = response.data['errors']['phone'];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          } else {
            // Handle cases where the error response doesn't match expected structure
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('An unexpected error occurred')),
            );
          }
        } else {
          // Handle cases where the response is null
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to login due to an unknown error')),
          );
        }
      } else {
        // Handle other types of exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to login due to network error')),
        );
      }
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
