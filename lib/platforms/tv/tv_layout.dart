import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../screens/task_list_screen.dart';
import '../../services/platform_service.dart';

class TVLayout extends StatefulWidget {
  const TVLayout({Key? key}) : super(key: key);

  @override
  State<TVLayout> createState() => _TVLayoutState();
}

class _TVLayoutState extends State<TVLayout> {
  final FocusNode _rootFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    PlatformService.setSystemUIMode(PlatformType.tv);
  }

  @override
  void dispose() {
    _rootFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _rootFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: const TaskListScreen(
        platformType: PlatformType.tv,
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.arrowRight:
          // Let the default focus handling manage navigation
          return KeyEventResult.ignored;
        
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
          // Handle selection
          return KeyEventResult.handled;
        
        case LogicalKeyboardKey.goBack:
        case LogicalKeyboardKey.escape:
          // Handle back navigation
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        
        default:
          return KeyEventResult.ignored;
      }
    }
    
    return KeyEventResult.ignored;
  }
}