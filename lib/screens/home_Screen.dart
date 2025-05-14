import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:camera/camera.dart';

import 'text_Screen.dart';
import 'money_Screen.dart' as money;
import 'object_Screen.dart' as object;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeCenterScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const WelcomeCenterScreen({super.key, required this.cameras});

  @override
  State<WelcomeCenterScreen> createState() => _WelcomeCenterScreenState();
}

class _WelcomeCenterScreenState extends State<WelcomeCenterScreen> {
  final FlutterTts tts = FlutterTts();
  List<CameraDescription> get cameras => widget.cameras;
  int currentIndex = 0;

  List<String> features = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = AppLocalizations.of(context)!;

    features = [
      locale.welcome,
      locale.moneyRecognition,
      locale.textRecognition,
      locale.objectDetection,
    ];

    _speakFeature();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _speakFeature() async {
    await tts.stop();

    Locale currentLocale = Localizations.localeOf(context);
    if (currentLocale.languageCode == 'ar') {
      await tts.setLanguage('ar-SA');
    } else if (currentLocale.languageCode == 'fr') {
      await tts.setLanguage('fr-FR');
    } else {
      await tts.setLanguage('en-US');
    }

    if (currentIndex == 0) {
      await tts.speak(AppLocalizations.of(context)!.welcome);
    } else {
      await tts.speak(
        "${features[currentIndex]}. ${AppLocalizations.of(context)!.doubleTap}",
      );
    }
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  void _nextFeature() {
    _vibrate();
    setState(() {
      currentIndex = (currentIndex + 1) % features.length;
    });
    _speakFeature();
  }

  void _prevFeature() {
    _vibrate();
    setState(() {
      currentIndex = (currentIndex - 1 + features.length) % features.length;
    });
    _speakFeature();
  }

  void _launchFeature() {
    _vibrate();
    switch (currentIndex) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => money.MoneyRecognitionScreen(camerass: cameras),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CameraScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => object.YoloVideo(camerass: cameras),
          ),
        );
        break;
    }
  }

  String getFeatureIconPath() {
    switch (currentIndex) {
      case 1:
        return 'assets/icons/moneyd.jpg';
      case 2:
        return 'assets/icons/textd.jpg';
      case 3:
        return 'assets/icons/objdet.jpg';
      default:
        return 'assets/icons/welcomep.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          _nextFeature();
        } else if (details.primaryVelocity! > 0) {
          _prevFeature();
        }
      },
      onDoubleTap: _launchFeature,
      onLongPress: _speakFeature,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 224, 228, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 224, 228, 255),
          elevation: 0,
          title: Text(locale.appTitle)
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 224, 228, 255), // Light purple-blue at top
                Color.fromARGB(255, 140, 143, 255), // Slightly darker purple-blue at bottom
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Feature title at the top - only for non-welcome screens
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: currentIndex != 0 
                  ? Text(
                      features[currentIndex],
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(230, 52, 19, 241),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : const SizedBox.shrink(), // Empty widget for welcome screen
              ),
              
              // Image container
              Positioned(
                top: 160,
                left: 45,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 166, 173, 250),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(40),
                    image: DecorationImage(
                      image: AssetImage(getFeatureIconPath()),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              //welcome to basira
              Positioned(
                bottom: 620,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: currentIndex == 0
                      ? Text(
                          locale.welcomword,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(230, 52, 19, 241),
                          ),
                          textAlign: TextAlign.center,
                        )
                      : SizedBox(),
                ),
              ),
              // Welcome message or instructions below the image
              Positioned(
                bottom: 140,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: currentIndex == 0
                      ? Text(
                          locale.instruction,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 66, 66, 66),
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          '${locale.swipeToChange}\n${locale.doubleTap}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 66, 66, 66),
                          ),
                          textAlign: TextAlign.center,
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