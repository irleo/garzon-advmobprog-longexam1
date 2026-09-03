import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/user_service.dart';
import '../session/session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class BouncingDotsLoader extends StatefulWidget {
  final Color color;
  final double dotSize;
  final double spacing;
  final Duration duration;

  const BouncingDotsLoader({
    super.key,
    required this.color,
    this.dotSize = 10,
    this.spacing = 8,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<BouncingDotsLoader> createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _y(int i) {
    final t = (_c.value + i * 0.16) % 1.0;
    final tri = t < 0.5 ? (t * 2) : (2 - t * 2);
    return -8 * Curves.easeInOut.transform(tri);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Padding(
              padding: EdgeInsets.only(right: i == 2 ? 0 : widget.spacing),
              child: Transform.translate(
                offset: Offset(0, _y(i)),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() => opacity = 1);
    });

    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final userService = UserService();
    try {
      final user = await userService.restoreUser();
      await Future<void>.delayed(const Duration(seconds: 3));
      Session.authenticatedUser = user;
    } catch (error) {
      debugPrint('Session restore failed: $error');
      Session.authenticatedUser = null;
    } finally {
      userService.dispose();
    }
    if (!mounted) return;
    final route = Session.authenticatedUser == null ? '/login' : '/home';
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                duration: const Duration(seconds: 1),
                opacity: opacity,
                child: Image.asset(
                  'assets/images/pongkan_logo_nobg.png',
                  height: 150,
                ),
              ),
              SizedBox(height: 30),
              BouncingDotsLoader(color: FB_DARK_PRIMARY),
            ],
          ),
        ),
      ),
    );
  }
}
