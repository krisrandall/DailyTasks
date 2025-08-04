import 'package:flutter/material.dart';
import '../models/task_enums.dart';
import '../utils/constants.dart';

class TaskCheckboxWidget extends StatelessWidget {
  final bool isCompleted;
  final RequiredType requiredType;
  final double size;
  final VoidCallback? onTap;
  final bool isAnimated;

  const TaskCheckboxWidget({
    Key? key,
    required this.isCompleted,
    required this.requiredType,
    this.size = AppConstants.iconSize,
    this.onTap,
    this.isAnimated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            requiredType == RequiredType.optional ? size / 2 : 4.0,
          ),
        ),
        child: isAnimated
            ? AnimatedSwitcher(
                duration: AppConstants.shortAnimation,
                child: _buildIcon(),
              )
            : _buildIcon(),
      ),
    );
  }

  Widget _buildIcon() {
    if (requiredType == RequiredType.daily) {
      return isCompleted
          ? Icon(
              Icons.check_box,
              size: size,
              color: AppConstants.completedColor,
              key: const ValueKey('completed_checkbox'),
            )
          : Icon(
              Icons.check_box_outline_blank,
              size: size,
              color: Colors.grey,
              key: const ValueKey('empty_checkbox'),
            );
    } else {
      // Optional tasks use circle icons
      return isCompleted
          ? Icon(
              Icons.radio_button_checked,
              size: size,
              color: AppConstants.completedColor,
              key: const ValueKey('completed_circle'),
            )
          : Icon(
              Icons.radio_button_unchecked,
              size: size,
              color: AppConstants.optionalColor,
              key: const ValueKey('empty_circle'),
            );
    }
  }
}

class AnimatedTaskCheckbox extends StatefulWidget {
  final bool isCompleted;
  final RequiredType requiredType;
  final double size;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const AnimatedTaskCheckbox({
    Key? key,
    required this.isCompleted,
    required this.requiredType,
    this.size = AppConstants.iconSize,
    this.onTap,
    this.animationDuration = AppConstants.mediumAnimation,
  }) : super(key: key);

  @override
  State<AnimatedTaskCheckbox> createState() => _AnimatedTaskCheckboxState();
}

class _AnimatedTaskCheckboxState extends State<AnimatedTaskCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isCompleted) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedTaskCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: TaskCheckboxWidget(
                isCompleted: widget.isCompleted,
                requiredType: widget.requiredType,
                size: widget.size,
                isAnimated: false,
              ),
            ),
          );
        },
      ),
    );
  }
}