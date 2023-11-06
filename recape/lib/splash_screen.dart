import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/logo.mp4')
      ..initialize().then((_) {
        _controller.setVolume(0.0); // Mute the video
        _controller.play();

        // After the video plays for 0.04 seconds, pause the video
        Future.delayed(const Duration(milliseconds: 40), () {
          _controller.pause();

          // Show the logo for an additional 8 seconds
          Future.delayed(const Duration(seconds: 8), () {
            // Navigate to the main screen
            Navigator.pushReplacementNamed(context, '/main');
          });
        });

        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
