import 'package:flutter/material.dart';

class AutoSlidingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Axis direction; // Added direction for horizontal or vertical sliding

  AutoSlidingText({
    required this.text,
    this.style,
    this.duration = const Duration(seconds: 5),
    this.direction = Axis.horizontal, // Default to horizontal sliding
  });

  @override
  _AutoSlidingTextState createState() => _AutoSlidingTextState();
}

class _AutoSlidingTextState extends State<AutoSlidingText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  @override
  void didUpdateWidget(covariant AutoSlidingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _animationController.duration = widget.duration;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling() {
    final double maxScrollExtent;
    if (widget.direction == Axis.horizontal) {
      maxScrollExtent = _scrollController.position.maxScrollExtent;
    } else {
      maxScrollExtent = _scrollController.position.maxScrollExtent;
    }

    if (maxScrollExtent > 0) {
      _animationController.reset();
      _animationController.forward().then((_) {
        _scrollController.jumpTo(0);
        _startScrolling(); // Loop the animation
      });

      _animationController.addListener(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            maxScrollExtent * _animationController.value,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: widget.direction,
      physics: const NeverScrollableScrollPhysics(), // Disable user scrolling
      child: Text(
        widget.text,
        style: widget.style,
        softWrap: false, // Prevent text wrapping
      ),
    );
  }
}
