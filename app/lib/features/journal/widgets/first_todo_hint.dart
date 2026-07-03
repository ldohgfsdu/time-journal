import 'package:flutter/material.dart';
import '../../../app/copy.dart';
import '../../../app/theme.dart';

/// 首次写下待办时的极淡破冰提示，淡入后自动淡出。
class FirstTodoHint extends StatefulWidget {
  const FirstTodoHint({super.key, required this.onDismissed});

  final VoidCallback onDismissed;

  @override
  State<FirstTodoHint> createState() => _FirstTodoHintState();
}

class _FirstTodoHintState extends State<FirstTodoHint> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _opacity = 1);
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => _opacity = 0);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) widget.onDismissed();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.only(left: 52, top: 2, bottom: 4),
        child: Text(
          AppCopy.journalFirstTodoHint,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.tomato.withValues(alpha: 0.45),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}