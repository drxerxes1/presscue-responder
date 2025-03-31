import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_icons.dart';
import 'package:presscue_patroller/core/constants/app_text.dart';
import 'package:presscue_patroller/core/navigation/app_routes.dart';

import '../../data/onboarding_content.dart';
import '../widgets/debug_modal.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      _currentPageIndex.value = _pageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double screenWidth = mediaQuery.size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.link, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const DebugModal(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackgroundImage(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.07),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  _buildLogo(),
                  SizedBox(height: screenHeight * 0.5),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: contents.length,
                      itemBuilder: (_, i) {
                        return AutoSizeText(
                          contents[i].description,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                  _buildDots(),
                  SizedBox(height: screenHeight * 0.03),
                  _buildGetStartedButton(context, screenHeight),
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/onboarding.png',
        fit: BoxFit.cover, // Ensures the image covers the entire background
      ),
    );
  }

  Widget _buildLogo() {
    return SvgPicture.asset(
      AppIcons.icResponder,
      fit: BoxFit.fill,
    );
  }

  Widget _buildDots() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ValueListenableBuilder<int>(
        valueListenable: _currentPageIndex,
        builder: (context, currentIndex, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              contents.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == currentIndex
                      ? AppColors.primaryColor
                      : AppColors
                          .accent, // Adjust color for active/inactive dots
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context, double screenHeight) {
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.07,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.loginPhoneNumber);
        },
        child: Text(
          'Login',
          style: AppText.subtitle1,
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.white,
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}
