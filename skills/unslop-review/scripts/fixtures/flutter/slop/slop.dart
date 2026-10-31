// Fixture: every line below is deliberate slop for slop-grep.sh to find.
import 'package:flutter/material.dart';

class SlopScreen extends StatelessWidget {
  const SlopScreen({super.key});

  Future<List<int>> load() async {
    try {
      return [1];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome back, Sam! 👋'.toUpperCase())),
      body: Container(
        padding: const EdgeInsets.only(top: 13, left: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.pinkAccent]),
          boxShadow: [BoxShadow(color: Color(0x668B5CF6), blurRadius: 30)],
        ),
        child: Column(children: [
          const SizedBox(height: 7),
          Text('Supercharge your workflow!',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.5,
                fontFamily: 'monospace',
                color: Colors.white,
              )),
          Text('Tap here to continue', textScaler: TextScaler.noScaling),
          const CircularProgressIndicator(),
          ListTile(title: Text('Row')),
          const Divider(),
          Card(child: Text('x')),
        ]),
      ),
    );
  }

  void animate(AnimationController c, int index) {
    c.repeat();
    final curve = Curves.bounceOut;
    final d = Duration(milliseconds: 600);
    final delay = Duration(milliseconds: 50 * index);
    BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10));
  }

  void moreSlop(BuildContext context) {
    ScaleTransition(scale: Tween<double>(begin: 0, end: 1).animate(kAlwaysCompleteAnimation));
    showDialog(context: context, barrierDismissible: false, builder: (_) => const SizedBox());
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    PopScope(canPop: false, child: const SizedBox());
    const Icon(Icons.menu);
    ListView(physics: const ClampingScrollPhysics());
    final a = Duration(seconds: 1);
  }
}
