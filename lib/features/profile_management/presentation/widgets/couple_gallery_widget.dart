import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/services/couple_gallery_service.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Couple gallery widget for profile screen
class CoupleGalleryWidget extends StatefulWidget {
  const CoupleGalleryWidget({super.key});

  @override
  State<CoupleGalleryWidget> createState() => _CoupleGalleryWidgetState();
}

class _CoupleGalleryWidgetState extends State<CoupleGalleryWidget> {
  final CoupleGalleryService _galleryService = CoupleGalleryService.instance;
  List<CouplePhoto> _recentPhotos = [];
  List<PhotoCollage> _recentCollages = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGalleryData();
  }

  Future<void> _loadGalleryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photos = await _galleryService.getAllPhotos();
      final collages = await _galleryService.getAllCollages();
      final stats = await _galleryService.getGalleryStatistics();

      setState(() {
        _recentPhotos = photos.take(6).toList();
        _recentCollages = collages.take(3).toList();
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: AppTheme.primaryPink,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Couple Gallery',
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Your shared photo memories',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showAddPhotoDialog,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.primaryPink,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryPink,
              ),
            )
          else if (_recentPhotos.isEmpty && _recentCollages.isEmpty)
            _buildEmptyState()
          else
            _buildGalleryContent(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.photo_camera_outlined,
          size: 48.w,
          color: AppTheme.textSecondary,
        ),
        SizedBox(height: 12.h),
        Text(
          'No photos yet',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Start capturing your beautiful moments together!',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: _showAddPhotoDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text('Add First Photo'),
        ),
      ],
    );
  }

  Widget _buildGalleryContent() {
    return Column(
      children: [
        // Statistics
        _buildStatistics(),
        SizedBox(height: 16.h),

        // Recent photos
        if (_recentPhotos.isNotEmpty) ...[
          _buildRecentPhotos(),
          SizedBox(height: 16.h),
        ],

        // Recent collages
        if (_recentCollages.isNotEmpty) ...[
          _buildRecentCollages(),
          SizedBox(height: 16.h),
        ],

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _showAddPhotoDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPink,
                  side: BorderSide(color: AppTheme.primaryPink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Add Photo'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _showCreateCollageDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Create Collage'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final totalPhotos = _statistics['totalPhotos'] ?? 0;
    final totalCollages = _statistics['totalCollages'] ?? 0;
    final favoritePhotos = _statistics['favoritePhotos'] ?? 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Photos',
              totalPhotos.toString(),
              Icons.photo,
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Collages',
              totalCollages.toString(),
              Icons.grid_view,
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Favorites',
              favoritePhotos.toString(),
              Icons.favorite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16.w,
          color: AppTheme.primaryPink,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: BabyFont.headingS.copyWith(
            color: AppTheme.primaryPink,
          ),
        ),
        Text(
          label,
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Photos',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 1.0,
          ),
          itemCount: _recentPhotos.length,
          itemBuilder: (context, index) {
            final photo = _recentPhotos[index];
            return _buildPhotoThumbnail(photo);
          },
        ),
      ],
    );
  }

  Widget _buildRecentCollages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Collages',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        ...(_recentCollages.map((collage) => _buildCollageItem(collage))),
      ],
    );
  }

  Widget _buildPhotoThumbnail(CouplePhoto photo) {
    return GestureDetector(
      onTap: () => _showPhotoDetails(photo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Stack(
            children: [
              // Photo
              if (File(photo.photoPath).existsSync())
                Image.file(
                  File(photo.photoPath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              else
                Container(
                  color: AppTheme.textSecondary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.broken_image,
                    color: AppTheme.textSecondary,
                    size: 24.w,
                  ),
                ),

              // Favorite indicator
              if (photo.isFavorite)
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 12.w,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollageItem(PhotoCollage collage) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Collage preview
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppTheme.primaryPink.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Text(
                collage.layout.emoji,
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Collage info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collage.title,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${collage.photoIds.length} photos • ${collage.layout.displayName}',
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (collage.description != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    collage.description!,
                    style: BabyFont.bodyS.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              if (collage.isFavorite)
                Icon(
                  Icons.favorite,
                  color: AppTheme.primaryPink,
                  size: 16.w,
                ),
              SizedBox(height: 4.h),
              Text(
                _formatDate(collage.createdAt),
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showAddPhotoDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPhotoDialog(
        onPhotoAdded: () {
          _loadGalleryData();
        },
      ),
    );
  }

  void _showCreateCollageDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateCollageDialog(
        onCollageCreated: () {
          _loadGalleryData();
        },
      ),
    );
  }

  void _showPhotoDetails(CouplePhoto photo) {
    showDialog(
      context: context,
      builder: (context) => PhotoDetailsDialog(photo: photo),
    );
  }
}

/// Add photo dialog
class AddPhotoDialog extends StatefulWidget {
  final VoidCallback onPhotoAdded;

  const AddPhotoDialog({
    super.key,
    required this.onPhotoAdded,
  });

  @override
  State<AddPhotoDialog> createState() => _AddPhotoDialogState();
}

class _AddPhotoDialogState extends State<AddPhotoDialog> {
  final CoupleGalleryService _galleryService = CoupleGalleryService.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String? _selectedPhotoPath;
  bool _isPrivate = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Photo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Photo selection
            GestureDetector(
              onTap: _selectPhoto,
              child: Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppTheme.primaryPink.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedPhotoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(_selectedPhotoPath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48.w,
                            color: AppTheme.primaryPink,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Tap to select photo',
                            style: BabyFont.bodyM.copyWith(
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 16.h),

            // Title input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Give your photo a title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Description input
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Tell the story behind this photo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16.h),

            // Tags input
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: 'Tags (optional)',
                hintText: 'vacation, anniversary, date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Privacy toggle
            Row(
              children: [
                Checkbox(
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value ?? false;
                    });
                  },
                  activeColor: AppTheme.primaryPink,
                ),
                Text('Keep this photo private'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _selectedPhotoPath != null && _titleController.text.isNotEmpty
                  ? _savePhoto
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
          ),
          child: Text('Add Photo'),
        ),
      ],
    );
  }

  Future<void> _selectPhoto() async {
    // TODO: Implement photo selection from gallery/camera
    // For now, we'll simulate a photo selection
    setState(() {
      _selectedPhotoPath = '/path/to/selected/photo.jpg';
    });
  }

  Future<void> _savePhoto() async {
    try {
      final tags = _tagsController.text.isNotEmpty
          ? _tagsController.text.split(',').map((tag) => tag.trim()).toList()
          : <String>[];

      final photo = CouplePhoto(
        id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        photoPath: _selectedPhotoPath!,
        tags: tags,
        isFavorite: false,
        isPrivate: _isPrivate,
        takenAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _galleryService.addCouplePhoto(photo);
      if (success && mounted) {
        Navigator.pop(context);
        widget.onPhotoAdded();
        ToastService.showSuccess(context, 'Photo added! 📸');
      } else {
        ToastService.showError(context, 'Failed to add photo');
      }
    } catch (e) {
      ToastService.showError(context, 'Failed to add photo: ${e.toString()}');
    }
  }
}

/// Create collage dialog
class CreateCollageDialog extends StatefulWidget {
  final VoidCallback onCollageCreated;

  const CreateCollageDialog({
    super.key,
    required this.onCollageCreated,
  });

  @override
  State<CreateCollageDialog> createState() => _CreateCollageDialogState();
}

class _CreateCollageDialogState extends State<CreateCollageDialog> {
  final CoupleGalleryService _galleryService = CoupleGalleryService.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  CollageLayout _selectedLayout = CollageLayout.grid2x2;
  List<String> _selectedPhotoIds = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Collage'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Layout selection
            Text(
              'Choose layout:',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildLayoutGrid(),
            SizedBox(height: 20.h),

            // Title input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Collage Title',
                hintText: 'Give your collage a title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Description input
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Describe your collage',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _titleController.text.isNotEmpty ? _createCollage : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
          ),
          child: Text('Create Collage'),
        ),
      ],
    );
  }

  Widget _buildLayoutGrid() {
    final layouts = CollageLayout.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: layouts.length,
      itemBuilder: (context, index) {
        final layout = layouts[index];
        final isSelected = _selectedLayout == layout;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedLayout = layout;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryPink.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryPink
                    : AppTheme.textSecondary.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  layout.emoji,
                  style: TextStyle(fontSize: 20.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  layout.displayName,
                  style: BabyFont.bodyS.copyWith(
                    color: isSelected
                        ? AppTheme.primaryPink
                        : AppTheme.textSecondary,
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createCollage() async {
    try {
      // TODO: Implement actual collage creation logic
      // For now, we'll create a placeholder collage
      final collage = PhotoCollage(
        id: 'collage_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        photoIds: _selectedPhotoIds,
        collagePath: '/path/to/collage.jpg', // TODO: Generate actual collage
        layout: _selectedLayout,
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _galleryService.addPhotoCollage(collage);
      if (success && mounted) {
        Navigator.pop(context);
        widget.onCollageCreated();
        ToastService.showSuccess(context, 'Collage created! 🎨');
      } else {
        ToastService.showError(context, 'Failed to create collage');
      }
    } catch (e) {
      ToastService.showError(
          context, 'Failed to create collage: ${e.toString()}');
    }
  }
}

/// Photo details dialog
class PhotoDetailsDialog extends StatelessWidget {
  final CouplePhoto photo;

  const PhotoDetailsDialog({
    super.key,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(photo.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Photo
            if (File(photo.photoPath).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  File(photo.photoPath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200.h,
                ),
              )
            else
              Container(
                height: 200.h,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    color: AppTheme.textSecondary,
                    size: 48.w,
                  ),
                ),
              ),

            SizedBox(height: 16.h),

            // Description
            if (photo.description != null) ...[
              Text(
                photo.description!,
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
            ],

            // Tags
            if (photo.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: photo.tags
                    .map((tag) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '#$tag',
                            style: BabyFont.bodyS.copyWith(
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 16.h),
            ],

            // Date
            Text(
              'Taken: ${photo.takenAt.day}/${photo.takenAt.month}/${photo.takenAt.year}',
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }
}
