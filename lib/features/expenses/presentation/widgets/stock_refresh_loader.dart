import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StockRefreshLoader extends StatefulWidget {
  final double size;
  final Color color;
  const StockRefreshLoader({
    Key? key,
    this.size = 64,
    this.color = CupertinoColors.activeBlue,
  }) : super(key: key);

  @override
  State<StockRefreshLoader> createState() => _StockRefreshLoaderState();
}

class _StockRefreshLoaderState extends State<StockRefreshLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating circular progress
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 6.28319, // 2*pi
                child: child,
              );
            },
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                backgroundColor: widget.color.withOpacity(0.1),
              ),
            ),
          ),
          // Stock icon in the center
          Icon(
            CupertinoIcons.cube_box,
            color: widget.color,
            size: widget.size * 0.5,
          ),
        ],
      ),
    );
  }
}
