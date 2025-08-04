import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/daily_task.dart';
import '../models/task_enums.dart';
import '../services/task_service.dart';
import '../services/media_service.dart';
import '../utils/constants.dart';
import '../utils/file_utils.dart';

class TaskEditScreen extends StatefulWidget {
  final DailyTask? task;

  const TaskEditScreen({Key? key, this.task}) : super(key: key);

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _folderController = TextEditingController();
  
  TaskType _selectedTaskType = TaskType.sequence;
  RequiredType _selectedRequiredType = RequiredType.daily;
  bool _isLoading = false;
  Map<String, dynamic>? _folderInfo;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (isEditing) {
      final task = widget.task!;
      _nameController.text = task.name;
      _folderController.text = task.onDeviceMediaFolder;
      _selectedTaskType = task.taskType;
      _selectedRequiredType = task.required;
      _validateFolder();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _folderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editTask : AppStrings.addTask),
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _deleteTask,
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: AppStrings.deleteTask,
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Task Name Field
          _buildTaskNameField(),
          
          const SizedBox(height: 24.0),
          
          // Media Folder Section
          _buildMediaFolderSection(),
          
          const SizedBox(height: 24.0),
          
          // Task Type Section
          _buildTaskTypeSection(),
          
          const SizedBox(height: 24.0),
          
          // Required Type Section
          _buildRequiredTypeSection(),
          
          const SizedBox(height: 24.0),
          
          // Folder Info Section
          if (_folderInfo != null) _buildFolderInfoSection(),
        ],
      ),
    );
  }

  Widget _buildTaskNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.taskName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter task name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.task),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a task name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMediaFolderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.mediaFolder,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _folderController,
          decoration: InputDecoration(
            hintText: 'Select media folder',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.folder),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _browseFolder,
                  icon: const Icon(Icons.folder_open),
                  tooltip: 'Browse Folder',
                ),
                IconButton(
                  onPressed: _validateFolder,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Check Folder',
                ),
              ],
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select a media folder';
            }
            return null;
          },
          onChanged: (value) {
            // Clear folder info when path changes
            setState(() {
              _folderInfo = null;
            });
            
            // Debounced validation
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_folderController.text == value && value.isNotEmpty) {
                _validateFolder();
              }
            });
          },
        ),
        const SizedBox(height: 8.0),
        _buildFolderSuggestions(),
      ],
    );
  }

  Widget _buildFolderSuggestions() {
    return FutureBuilder<List<String>>(
      future: FileUtils.getCommonMediaDirectories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Common folders:',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: snapshot.data!.map((folder) {
                return ActionChip(
                  label: Text(
                    folder.split('/').last,
                    style: const TextStyle(fontSize: 12.0),
                  ),
                  onPressed: () {
                    _folderController.text = folder;
                    _validateFolder();
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.taskType,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                RadioListTile<TaskType>(
                  title: const Text(AppStrings.sequence),
                  subtitle: const Text('Play media files in order'),
                  value: TaskType.sequence,
                  groupValue: _selectedTaskType,
                  onChanged: (value) {
                    setState(() {
                      _selectedTaskType = value!;
                    });
                  },
                ),
                RadioListTile<TaskType>(
                  title: const Text(AppStrings.choose),
                  subtitle: const Text('Choose which media file to play'),
                  value: TaskType.choose,
                  groupValue: _selectedTaskType,
                  onChanged: (value) {
                    setState(() {
                      _selectedTaskType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.required,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                RadioListTile<RequiredType>(
                  title: const Text(AppStrings.daily),
                  subtitle: const Text('Must be completed daily'),
                  value: RequiredType.daily,
                  groupValue: _selectedRequiredType,
                  onChanged: (value) {
                    setState(() {
                      _selectedRequiredType = value!;
                    });
                  },
                ),
                RadioListTile<RequiredType>(
                  title: const Text(AppStrings.optional),
                  subtitle: const Text('Optional, can be completed when desired'),
                  value: RequiredType.optional,
                  groupValue: _selectedRequiredType,
                  onChanged: (value) {
                    setState(() {
                      _selectedRequiredType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFolderInfoSection() {
    final info = _folderInfo!;
    final folderExists = info['folderExists'] as bool;
    final totalFiles = info['totalFiles'] as int;
    final videoFiles = info['videoFiles'] as int;
    final audioFiles = info['audioFiles'] as int;

    return Card(
      color: folderExists 
          ? AppConstants.completedColor.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  folderExists ? Icons.check_circle : Icons.error,
                  color: folderExists ? AppConstants.completedColor : Colors.red,
                ),
                const SizedBox(width: 8.0),
                Text(
                  folderExists ? 'Folder Found' : 'Folder Not Found',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: folderExists ? AppConstants.completedColor : Colors.red,
                  ),
                ),
              ],
            ),
            
            if (folderExists) ...[
              const SizedBox(height: 12.0),
              Row(
                children: [
                  _buildInfoChip('Total', totalFiles.toString(), Icons.folder),
                  const SizedBox(width: 8.0),
                  _buildInfoChip('Video', videoFiles.toString(), Icons.video_file),
                  const SizedBox(width: 8.0),
                  _buildInfoChip('Audio', audioFiles.toString(), Icons.audio_file),
                ],
              ),
              
              if (totalFiles == 0) ...[
                const SizedBox(height: 8.0),
                Text(
                  'No media files found in this folder',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12.0,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.0,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 4.0),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(width: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancel),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveTask,
              child: _isLoading
                  ? const SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    )
                  : const Text(AppStrings.save),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _browseFolder() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      
      if (selectedDirectory != null) {
        _folderController.text = selectedDirectory;
        await _validateFolder();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting folder: $e')),
      );
    }
  }

  Future<void> _validateFolder() async {
    final folderPath = _folderController.text.trim();
    if (folderPath.isEmpty) return;

    try {
      final mediaService = context.read<MediaService>();
      final folderInfo = await mediaService.getMediaFolderInfo(folderPath);
      
      setState(() {
        _folderInfo = folderInfo;
      });
    } catch (e) {
      setState(() {
        _folderInfo = {
          'folderExists': false,
          'totalFiles': 0,
          'videoFiles': 0,
          'audioFiles': 0,
        };
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final taskService = context.read<TaskService>();
      
      if (isEditing) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          name: _nameController.text.trim(),
          onDeviceMediaFolder: _folderController.text.trim(),
          taskType: _selectedTaskType,
          required: _selectedRequiredType,
        );
        
        await taskService.updateTask(updatedTask);
      } else {
        // Create new task
        final newTask = taskService.createNewTask(
          name: _nameController.text.trim(),
          onDeviceMediaFolder: _folderController.text.trim(),
          taskType: _selectedTaskType,
          required: _selectedRequiredType,
        );
        
        await taskService.addTask(newTask);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Task updated' : 'Task created'),
            backgroundColor: AppConstants.completedColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _deleteTask() {
    if (!isEditing) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTask),
        content: Text('Are you sure you want to delete "${widget.task!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              try {
                await context.read<TaskService>().deleteTask(widget.task!.id);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task deleted'),
                      backgroundColor: AppConstants.completedColor,
                    ),
                  );
                  Navigator.pop(context); // Close edit screen
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting task: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
}