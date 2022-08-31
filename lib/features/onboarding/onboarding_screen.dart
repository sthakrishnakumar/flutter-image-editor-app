import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_editor/features/edit_image/select_image_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _ClassNameState();
}

class _ClassNameState extends State<OnboardingScreen> {
  final controller = PageController();
  bool isLastPage = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final Color color = Colors.purple[100]!;
    List<BuildPage> onboards = [
      BuildPage(
        color: color,
        urlImage: 'assets/onboard1.png',
        title: 'Hello 1',
        subtitle: 'This is on board page',
      ),
      BuildPage(
        color: color,
        urlImage: 'assets/onboard2.png',
        title: 'Hello 2',
        subtitle: 'This is on board page',
      ),
      BuildPage(
        color: color,
        urlImage: 'assets/onboard3.png',
        title: 'Hello 3',
        subtitle: 'This is on board page',
      ),
    ];

    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.only(bottom: height * 0.08),
          child: PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            children: [
              ...onboards,
            ],
          ),
        ),
        bottomSheet: isLastPage
            ? Consumer(builder: (context, ref, child) {
                return TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    primary: Colors.white,
                    backgroundColor: Colors.teal.shade700,
                    minimumSize: Size.fromHeight(height * 0.085),
                  ),
                  onPressed: () async {
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const Dashboard(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                );
              })
            : Container(
                padding: EdgeInsets.symmetric(horizontal: width * 0.01),
                color: Colors.purple[100],
                height: height * 0.08,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => controller.jumpToPage(3),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    SmoothPageIndicator(
                      controller: controller,
                      count: 3,
                      onDotClicked: (index) => controller.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                      effect: WormEffect(
                        activeDotColor: Colors.green,
                        dotHeight: height * 0.010,
                        dotWidth: width * 0.02,
                      ),
                    ),
                    TextButton(
                      onPressed: () => controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class BuildPage extends StatelessWidget {
  BuildPage({
    Key? key,
    required this.color,
    required this.urlImage,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  Color color;
  String urlImage;
  String title;
  String subtitle;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 20,
            child: Image.asset(
              urlImage,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
