import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:myapp/main.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // MODIFIED: Removed the 'artboard' parameter to make it bulletproof
  final List<Map<String, String>> _onboardingData = [
    {
      'rive_asset': 'assets/riv/working.riv',
      'headline': 'Welcome to ConvoSense AI',
      'text':
          'Unlock powerful insights from your conversations. The future of communication analysis is here.',
    },
    {
      'rive_asset': 'assets/riv/devai.riv',
      'headline': 'Intelligent Call Summaries',
      'text':
          'Instantly get the gist of any conversation with AI-powered summaries and key topic identification.',
    },
    {
      'rive_asset': 'assets/riv/manhomelap.riv',
      'headline': 'Seamless Integration & Dashboards',
      'text':
          'Visualize your call data in beautiful, real-time dashboards and connect with your favorite tools.',
    },
  ];

  final List<CustomClipper<Path>> _clippers = [
    ScribbleClipper(),
    WavyClipper(), // The improved WavyClipper is below
    BlobClipper(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onIntroEnd() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        material.MaterialPageRoute(builder: (_) => const MyApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return material.Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                riveAsset: _onboardingData[index]['rive_asset']!,
                headline: _onboardingData[index]['headline']!,
                text: _onboardingData[index]['text']!,
                clipper: _clippers[index],
                pageController: _pageController,
                index: index,
              );
            },
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => buildDot(index: index),
                  ),
                ),
                const SizedBox(height: 40),
                _buildBottomButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        material.TextButton(
          onPressed: _onIntroEnd,
          child: const Text(
            'Skip',
            style: TextStyle(color: material.Colors.white70),
          ),
        ),
        material.ElevatedButton(
          onPressed: () {
            if (_currentPage == _onboardingData.length - 1) {
              _onIntroEnd();
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
          style: material.ElevatedButton.styleFrom(
            backgroundColor: material.Theme.of(context).primaryColor,
            shape: material.RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          ),
          child: Text(
            _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next',
            style: const TextStyle(color: material.Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? material.Theme.of(context).primaryColor
            : const Color(0xFFD8D8D8),

        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  final String riveAsset;
  final String headline;
  final String text;
  final CustomClipper<Path> clipper;
  final PageController pageController;
  final int index;

  const OnboardingPage({
    super.key,
    required this.riveAsset,
    required this.headline,
    required this.text,
    required this.clipper,
    required this.pageController,
    required this.index,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          // MODIFIED: Removed artboard parameter
          child: RiveAnimation.asset(widget.riveAsset, fit: BoxFit.cover),
        ),
        
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: material.LinearGradient(
                  colors: [
                    material.Colors.black.withAlpha(128),
                    material.Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(40, 80, 40, 150),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: AnimatedBuilder(
                  animation: widget.pageController,
                  builder: (context, child) {
                    double pageValue = widget.pageController.hasClients
                        ? widget.pageController.page ?? widget.index.toDouble()
                        : widget.index.toDouble();

                    double value = pageValue - widget.index;
                    double opacity = (1 - value.abs()).clamp(0.0, 1.0);
                    double transformX = pageValue - widget.index;

                    return Opacity(
                      opacity: opacity,
                      child: Transform.translate(
                        offset: Offset(
                          -transformX *
                              material.MediaQuery.of(context).size.width /
                              1.5,
                          0,
                        ),
                        child: child,
                      ),
                    );
                  },

                  child: ClipPath(
                    clipper: widget.clipper,
                    // MODIFIED: Removed artboard parameter
                    child: RiveAnimation.asset(
                      widget.riveAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Expanded(
                flex: 2,

                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        widget.headline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: material.Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        widget.text,

                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          fontSize: 16,

                          color: material.Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- CUSTOM CLIPPERS ---

class ScribbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.05, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.0,
      size.height * 0.4,
      size.width * 0.1,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.8,
      size.width * 0.4,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 1.0,
      size.width * 0.8,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 1.0,
      size.height * 0.8,
      size.width * 0.9,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.2,
    );
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.0,
      size.width * 0.2,
      size.height * 0.1,
    );
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.15,
      size.width * 0.05,
      size.height * 0.2,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// This version keeps the top 10% of the area completely open
// so heads/top parts are never cut off.
class WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.05); // Start near the top
    path.quadraticBezierTo(
      size.width * 0.5,
      -20,
      size.width * 0.9,
      size.height * 0.05,
    );
    path.lineTo(size.width, size.height * 0.5);
    path.quadraticBezierTo(
      size.width,
      size.height * 0.9,
      size.width * 0.5,
      size.height,
    );
    path.quadraticBezierTo(0, size.height * 0.9, 0, size.height * 0.5);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.cubicTo(
      size.width * 0.9,
      0,
      size.width,
      size.height * 0.4,
      size.width,
      size.height * 0.5,
    );
    path.cubicTo(
      size.width,
      size.height * 0.9,
      size.width * 0.7,
      size.height,
      size.width * 0.5,
      size.height,
    );
    path.cubicTo(
      size.width * 0.3,
      size.height,
      0,
      size.height * 0.8,
      0,
      size.height * 0.5,
    );
    path.cubicTo(
      0,
      size.height * 0.2,
      size.width * 0.1,
      0,
      size.width * 0.5,
      0,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
