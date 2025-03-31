import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_text.dart';
import 'package:presscue_patroller/core/services/base_url_provider.dart';
import 'package:presscue_patroller/core/utils/slide_page_route.dart';
import 'package:presscue_patroller/features/auth/login_password_page.dart';
import 'package:presscue_patroller/features/auth/validate_phone_number.dart';

class LoginPhoneNumberPage extends ConsumerStatefulWidget {
  const LoginPhoneNumberPage({super.key});

  @override
  _LoginPhoneNumberPageState createState() => _LoginPhoneNumberPageState();
}

class _LoginPhoneNumberPageState extends ConsumerState<LoginPhoneNumberPage> {
  final TextEditingController _phoneController = TextEditingController();
  String countryCode = '+63'; // Default country code for the Philippines
  final ValidatePhoneNumber _phoneValidator = ValidatePhoneNumber();

  @override
  void dispose() {
    _phoneController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(mediaQuery.size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: mediaQuery.size.height * 0.1),
              _buildWelcomeText(),
              SizedBox(height: 16),
              _buildSubText(),
              SizedBox(height: mediaQuery.size.height * 0.05),
              Row(
                children: [
                  CountryCodePicker(
                    initialSelection: 'PH',
                    favorite: const ['+63', 'PH'],
                    showCountryOnly: false,
                    flagWidth: 24,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    onChanged: (CountryCode code) {
                      setState(() {
                        countryCode = code.dialCode ?? '+63';
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller:
                          _phoneController, // Bind controller to TextField
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: AppColors.muted),
                        hintText: 'Phone Number',
                        border: _buildOutlineInputBorder(AppColors.textField),
                        filled: true,
                        fillColor: AppColors.textField,
                        enabledBorder:
                            _buildOutlineInputBorder(AppColors.textField),
                        focusedBorder:
                            _buildOutlineInputBorder(AppColors.textField),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 20.0),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    final phoneNumber = _phoneController.text;
                    final validationMessage = _phoneValidator.call(phoneNumber);

                    String url = await BaseUrlProvider.baseUrl;
                    print("Current Base URL: ${url}");

                    if (validationMessage != '') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(validationMessage.toString()),
                        ),
                      );
                    } else {
                      final fullPhoneNumber = '$countryCode$phoneNumber';
                      print('Phone Number: $fullPhoneNumber');

                      Navigator.push(
                        context,
                        SlidePageRoute(
                          builder: (context) =>
                              LoginPasswordPage(phoneNumber: fullPhoneNumber),
                          transitionType:
                              SlidePageTransitionType.slideFromRight,
                        ),
                      );
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
              ),
              SizedBox(height: mediaQuery.size.height * 0.02),
              _buildSignInWithEmailButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Text(
      'Welcome back!\nEnter your number',
      style: AppText.header2,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubText() {
    return Text(
      'We\'ll text you a code to log in.',
      style: AppText.subtitle3,
      textAlign: TextAlign.center,
    );
  }

  OutlineInputBorder _buildOutlineInputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _buildSignInWithEmailButton() {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
      ),
      child: const Text(
        'Sign in with email',
        style: AppText.body2,
      ),
    );
  }
}
