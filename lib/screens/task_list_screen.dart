import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_task.dart';
import '../models/task_enums.dart';
import '../services/task_service.dart';
import '../services/media_service.dart';
import '../services/platform_service.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as date_utils;
import '../widgets/task_item_widget.dart';
import 'media_chooser_screen.dart';
import 'media_player_screen.dart';
import 'task_edit_screen.dart';

class TaskListScreen extends StatefulWidget {
  final PlatformType platformType;

  const TaskListScreen({
    Key? key,
    this.platformType = PlatformType.mobile,
  }) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int _focusedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final Map<String, int> _mediaFileCounts = {};

  @override
  void initState() {
    super.initState();
    _loadMediaFileCounts();
    
    // Set up periodic midnight check
    _scheduleMidnightCheck();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleMidnightCheck() {
    // Check for midnight reset every minute
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        context.read<TaskService>().checkMidnightReset();
        _scheduleMidnightCheck();
      }
    });
  }

  Future<void> _loadMediaFileCounts() async {
    final taskService = context.read<TaskService>();
    final mediaService = context.read<MediaService>();
    
    for (final task in taskService.tasks) {
      final count = await mediaService.getMediaFileCount(task.onDeviceMediaFolder);
      if (mounted) {
        setState(() {
          _mediaFileCounts[task.id] = count;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: widget.platformType != PlatformType.widget
          ? _buildFloatingActionButton()
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (widget.platformType == PlatformType.widget) {
      return const PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: SizedBox.shrink(),
      );
    }

    return AppBar(
      title: const Text(AppStrings.appTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshTasks,
          tooltip: 'Refresh',
        ),
        if (widget.platformType != PlatformType.tv)
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('Export Tasks'),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Text('Import Tasks'),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset All Tasks'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        if (taskService.tasks.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _refreshTasks,
          child: _buildTaskList(taskService),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80.0,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16.0),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Add your first daily task to get started',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: _addNewTask,
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(TaskService taskService) {
    final dailyTasks = taskService.dailyTasks;
    final optionalTasks = taskService.optionalTasks;
    
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Progress indicator
        if (widget.platformType != PlatformType.widget && dailyTasks.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildProgressIndicator(taskService),
          ),
        
        // Daily tasks section
        if (dailyTasks.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader(AppStrings.pendingTasks, dailyTasks.length),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildTaskItem(dailyTasks[index], index),
              childCount: dailyTasks.length,
            ),
          ),
        ],
        
        // Optional tasks section
        if (optionalTasks.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader(AppStrings.optionalTasks, optionalTasks.length),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildTaskItem(
                optionalTasks[index], 
                dailyTasks.length + index,
              ),
              childCount: optionalTasks.length,
            ),
          ),
        ],
        
        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 80.0),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(TaskService taskService) {
    final progress = taskService.completionProgress;
    final completed = taskService.completedDailyTasks.length;
    final total = taskService.dailyTasks.length;
    
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completed / $total',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? AppConstants.completedColor : AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            progress == 1.0 
              ? '🎉 All daily tasks completed!'
              : 'Keep going! ${total - completed} tasks remaining',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(DailyTask task, int index) {
    if (widget.platformType == PlatformType.widget) {
      return CompactTaskItemWidget(
        task: task,
        onTap: () => _handleTaskTap(task),
      );
    }

    return TaskItemWidget(
      task: task,
      onTap: () => _handleTaskTap(task),
      onLongPress: () => _handleTaskLongPress(task),
      platformType: widget.platformType,
      isFocused: widget.platformType == PlatformType.tv && index == _focusedIndex,
      mediaFileCount: _mediaFileCounts[task.id],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _addNewTask,
      child: const Icon(Icons.add),
      tooltip: AppStrings.addTask,
    );
  }

  Future<void> _handleTaskTap(DailyTask task) async {
    if (task.isCompletedToday) {
      // Already completed, maybe show a message or replay
      _showTaskCompletedDialog(task);
      return;
    }

    final mediaService = context.read<MediaService>();
    
    if (task.taskType == TaskType.sequence) {
      // Get next media file in sequence
      final nextMedia = await mediaService.getNextMediaFile(task);
      if (nextMedia != null) {
        _playMediaFile(task, nextMedia);
      } else {
        _showNoMediaDialog(task);
      }
    } else {
      // Show media chooser
      _showMediaChooser(task);
    }
  }

  void _handleTaskLongPress(DailyTask task) {
    if (widget.platformType == PlatformType.tv) {
      // TV uses different interaction
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => _buildTaskOptionsSheet(task),
    );
  }

  Widget _buildTaskOptionsSheet(DailyTask task) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            task.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16.0),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Task'),
            onTap: () {
              Navigator.pop(context);
              _editTask(task);
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('View Folder'),
            onTap: () {
              Navigator.pop(context);
              _showMediaChooser(task);
            },
          ),
          if (task.isCompletedToday)
            ListTile(
              leading: const Icon(Icons.replay),
              title: const Text('Mark as Pending'),
              onTap: () {
                Navigator.pop(context);
                _markTaskPending(task);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Task', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteTask(task);
            },
          ),
        ],
      ),
    );
  }

  void _showMediaChooser(DailyTask task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaChooserScreen(
          task: task,
          onMediaSelected: (mediaFile) => _playMediaFile(task, mediaFile),
        ),
      ),
    );
  }

  void _playMediaFile(DailyTask task, MediaFile mediaFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaPlayerScreen(
          task: task,
          mediaFile: mediaFile,
          onMediaCompleted: () => _markTaskCompleted(task, mediaFile),
        ),
      ),
    );
  }

  void _markTaskCompleted(DailyTask task, MediaFile mediaFile) {
    context.read<TaskService>().markTaskCompleted(
      task.id,
      mediaFile.file.path,
    );
  }

  void _markTaskPending(DailyTask task) {
    final updatedTask = task.copyWith(isCompletedToday: false);
    context.read<TaskService>().updateTask(updatedTask);
  }

  void _addNewTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskEditScreen(),
      ),
    ).then((_) => _loadMediaFileCounts());
  }

  void _editTask(DailyTask task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskEditScreen(task: task),
      ),
    ).then((_) => _loadMediaFileCounts());
  }

  void _deleteTask(DailyTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TaskService>().deleteTask(task.id);
              _loadMediaFileCounts();
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskCompletedDialog(DailyTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task Completed'),
        content: Text('You have already completed "${task.name}" today!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _markTaskPending(task);
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _showNoMediaDialog(DailyTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Media Found'),
        content: Text('No media files found in the folder for "${task.name}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editTask(task);
            },
            child: const Text('Edit Folder'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshTasks() async {
    await context.read<TaskService>().loadTasks();
    await context.read<MediaService>().clearCache();
    await _loadMediaFileCounts();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportTasks();
        break;
      case 'import':
        _importTasks();
        break;
      case 'reset':
        _resetAllTasks();
        break;
    }
  }

  void _exportTasks() {
    final taskService = context.read<TaskService>();
    final exportData = taskService.exportTasks();
    
    // TODO: Show share dialog or save to file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  void _importTasks() {
    // TODO: Show file picker and import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import functionality coming soon')),
    );
  }

  void _resetAllTasks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Tasks'),
        content: const Text('Are you sure you want to reset all tasks? This will mark all completed tasks as pending.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TaskService>().resetDailyTasks();
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}