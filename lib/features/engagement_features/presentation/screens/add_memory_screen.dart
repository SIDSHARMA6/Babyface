import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../providers/memory_journal_provider.dart';
import '../../data/models/memory_model.dart';
import '../widgets/voice_recording_widget.dart';

/// Add Memory Screen
/// Follows memory_journey.md specification with photo support
class AddMemoryScreen extends ConsumerStatefulWidget {
  final MemoryModel? existingMemory;

  const AddMemoryScreen({
    super.key,
    this.existingMemory,
  });

  @override
  ConsumerState<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends ConsumerState<AddMemoryScreen>
    with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedEmoji = '💕';
  String _selectedMood = 'joyful';
  File? _selectedPhoto;
  // String? _voicePath;
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _emojiController = TextEditingController();

  final List<String> _emojis = [
    '💕',
    '💖',
    '💗',
    '💝',
    '💘',
    '💞',
    '💓',
    '💟',
    '🌹',
    '🌸',
    '🌺',
    '🌻',
    '🌷',
    '🌼',
    '🌿',
    '🍀',
    '🎂',
    '🍰',
    '🍭',
    '🍫',
    '🍩',
    '🍪',
    '☕',
    '🍷',
    '🎵',
    '🎶',
    '🎤',
    '🎧',
    '🎸',
    '🎹',
    '🎺',
    '🎻',
    '📸',
    '📷',
    '🎬',
    '🎭',
    '🎨',
    '🖼️',
    '🖌️',
    '🖍️',
    '✈️',
    '🚗',
    '🚲',
    '🏖️',
    '🏔️',
    '🌊',
    '🌅',
    '🌄',
    '🏠',
    '🏡',
    '🏘️',
    '🏰',
    '🏛️',
    '🏗️',
    '🏢',
    '🏬',
    '👫',
    '👨‍👩‍👧‍👦',
    '👨‍👨‍👧',
    '👩‍👩‍👦',
    '👨‍👧',
    '👩‍👦',
    '👨‍👧‍👦',
    '👩‍👧‍👦',
  ];

  final Map<String, String> _moods = {
    'joyful': '😊 Joyful',
    'sweet': '💕 Sweet',
    'emotional': '🥺 Emotional',
    'romantic': '💖 Romantic',
    'fun': '😄 Fun',
    'excited': '🤩 Excited',
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _populateFieldsForEdit();
  }

  void _populateFieldsForEdit() {
    if (widget.existingMemory != null) {
      final memory = widget.existingMemory!;
      _titleController.text = memory.title;
      _descriptionController.text = memory.description;
      _selectedEmoji = memory.emoji;
      _selectedMood = memory.mood;
      // _voicePath = memory.voicePath;
      _tags.addAll(memory.tags);
      if (memory.location != null) {
        _locationController.text = memory.location!;
      }
      if (memory.photoPath != null) {
        _selectedPhoto = File(memory.photoPath!);
      }
    }
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    _emojiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoryState = ref.watch(memoryJournalProvider);
    final memoryNotifier = ref.read(memoryJournalProvider.notifier);

    // Listen for errors
    ref.listen<MemoryJournalState>(memoryJournalProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.errorMessage}')),
        );
        memoryNotifier.clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.existingMemory != null ? 'Edit Memory 💕' : 'Add Memory 💕',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.primaryPink,
            size: 20.w,
          ),
        ),
        actions: [
          TextButton(
            onPressed: memoryState.isAddingMemory ? null : _saveMemory,
            child: Text(
              'Save',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(),
              SizedBox(height: 20.h),
              _buildDatePicker(),
              SizedBox(height: 20.h),
              _buildEmojiInput(),
              SizedBox(height: 20.h),
              _buildEmojiSelector(),
              SizedBox(height: 20.h),
              _buildMoodSelector(),
              SizedBox(height: 20.h),
              _buildPhotoSection(),
              SizedBox(height: 20.h),
              _buildVoiceSection(),
              SizedBox(height: 20.h),
              _buildDescriptionField(),
              SizedBox(height: 20.h),
              _buildLocationField(),
              SizedBox(height: 20.h),
              _buildTagsSection(),
              SizedBox(height: 40.h),
              _buildSaveButton(memoryState.isAddingMemory),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Memory Title',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g., Our First Date 💕',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: AppTheme.primaryPink, width: 2.w),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          style: BabyFont.bodyM.copyWith(color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Memory Date',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.primaryPink,
                  size: 20.w,
                ),
                SizedBox(width: 12.w),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.textSecondary,
                  size: 20.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Emoji (Optional)',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _emojiController,
          decoration: InputDecoration(
            hintText: 'Enter a custom emoji (e.g., 💕)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: AppTheme.primaryPink, width: 2.w),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            suffixIcon: IconButton(
              onPressed: () {
                if (_emojiController.text.isNotEmpty) {
                  setState(() {
                    _selectedEmoji = _emojiController.text;
                  });
                  HapticFeedback.selectionClick();
                }
              },
              icon: Icon(Icons.check, color: AppTheme.primaryPink),
            ),
          ),
          style: BabyFont.bodyM.copyWith(color: AppTheme.textPrimary),
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _selectedEmoji = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildEmojiSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose from Popular Emojis',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: GridView.builder(
            padding: EdgeInsets.all(8.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 4.h,
            ),
            itemCount: _emojis.length,
            itemBuilder: (context, index) {
              final emoji = _emojis[index];
              final isSelected = emoji == _selectedEmoji;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEmoji = emoji;
                    _emojiController.text = emoji;
                  });
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryPink.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    border: isSelected
                        ? Border.all(color: AppTheme.primaryPink, width: 2.w)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: _moods.entries.map((entry) {
            final isSelected = entry.key == _selectedMood;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMood = entry.key;
                });
                HapticFeedback.selectionClick();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryPink : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryPink
                        : AppTheme.borderLight,
                    width: isSelected ? 2.w : 1.w,
                  ),
                ),
                child: Text(
                  entry.value,
                  style: BabyFont.bodyS.copyWith(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo (Optional)',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _selectPhoto,
          child: Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: _selectedPhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: Image.file(
                      _selectedPhoto!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        color: AppTheme.primaryPink,
                        size: 32.w,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Tap to add photo',
                        style: BabyFont.bodyS.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_selectedPhoto != null) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              TextButton.icon(
                onPressed: _selectPhoto,
                icon: Icon(Icons.edit, size: 16.w),
                label: Text('Change Photo'),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedPhoto = null;
                  });
                },
                icon: Icon(Icons.delete, size: 16.w, color: Colors.red),
                label: Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVoiceSection() {
    return VoiceRecordingWidget(
      initialVoicePath: null, // _voicePath,
      onVoiceRecorded: (voicePath) {
        setState(() {
          // _voicePath = voicePath;
        });
      },
      isEnabled: true,
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe this beautiful moment...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: AppTheme.primaryPink, width: 2.w),
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
          style: BabyFont.bodyM.copyWith(color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location (Optional)',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'e.g., Central Park, New York',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: AppTheme.primaryPink, width: 2.w),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          style: BabyFont.bodyM.copyWith(color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (Optional)',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'Add tag...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(color: AppTheme.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide:
                        BorderSide(color: AppTheme.primaryPink, width: 2.w),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                style: BabyFont.bodyM.copyWith(color: AppTheme.textPrimary),
                onSubmitted: _addTag,
              ),
            ),
            SizedBox(width: 8.w),
            IconButton(
              onPressed: () => _addTag(_tagController.text),
              icon: Icon(Icons.add, color: AppTheme.primaryPink),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style:
                          BabyFont.bodyS.copyWith(color: AppTheme.primaryPink),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: () => _removeTag(tag),
                      child: Icon(
                        Icons.close,
                        size: 16.w,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton(bool isSaving) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSaving ? null : _saveMemory,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPink,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          elevation: 8,
          shadowColor: AppTheme.primaryPink.withValues(alpha: 0.3),
        ),
        child: isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Saving Memory...',
                    style: BabyFont.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    'Save Memory 💕',
                    style: BabyFont.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _selectPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedPhoto = File(image.path);
        });
        HapticFeedback.lightImpact();
        if (mounted) {
          ToastService.showBabyMessage(context, 'Photo selected! 📸✨');
        }
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(
            context, 'Failed to select photo: ${e.toString()}');
      }
    }
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
      setState(() {
        _tags.add(tag.trim());
        _tagController.clear();
      });
      HapticFeedback.selectionClick();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    HapticFeedback.selectionClick();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryPink,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _saveMemory() async {
    if (_titleController.text.trim().isEmpty) {
      ToastService.showError(context, 'Please enter a title for your memory');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ToastService.showError(
          context, 'Please enter a description for your memory');
      return;
    }

    final memoryNotifier = ref.read(memoryJournalProvider.notifier);

    if (widget.existingMemory != null) {
      // Update existing memory
      await memoryNotifier.updateMemoryWithParams(
        widget.existingMemory!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        emoji: _selectedEmoji,
        photoPath: _selectedPhoto?.path,
        voicePath: null, // _voicePath,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        tags: _tags,
        mood: _selectedMood,
      );

      if (mounted) {
        ToastService.showCelebration(
            context, 'Memory updated successfully! 💕✨');
        Navigator.pop(context);
      }
    } else {
      // Create new memory
      await memoryNotifier.addMemory(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        emoji: _selectedEmoji,
        photoPath: _selectedPhoto?.path,
        voicePath: null, // _voicePath,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        tags: _tags,
        mood: _selectedMood,
        date: _selectedDate,
      );

      if (mounted) {
        ToastService.showCelebration(context, 'Memory saved successfully! 💕✨');
        Navigator.pop(context);
      }
    }
  }
}
