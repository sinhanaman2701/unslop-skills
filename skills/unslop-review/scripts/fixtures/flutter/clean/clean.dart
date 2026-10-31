// Fixture: idiomatic iOS-first code that slop-grep.sh must NOT flag.
import 'package:flutter/cupertino.dart';

abstract final class Space {
  static const double s8 = 8, s16 = 16, s24 = 24;
}

class CleanScreen extends StatelessWidget {
  const CleanScreen({super.key, required this.rows});
  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    final label = CupertinoColors.label.resolveFrom(context);
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('October 2026')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Revenue', style: TextStyle(color: label, fontWeight: FontWeight.w600)),
              const SizedBox(height: Space.s8),
              Text('+12% vs last month', style: TextStyle(color: label)),
              const SizedBox(height: 24),
              for (final r in rows) Text(r),
            ],
          ),
        ),
      ),
    );
  }
}
