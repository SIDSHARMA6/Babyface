import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/memory_journey_entity.dart';
import '../../data/models/memory_model.dart';
import '../providers/memory_journey_provider.dart';
import '../providers/memory_journal_provider.dart';
import '../widgets/complete_memory_journey_visualizer.dart';
import '../services/feedback_system.dart';
import '../widgets/memory_card.dart';

/// Memory Journey Preview Screen
/// Screen that shows the "Preview Your Journey" button and launches the visualizer
class MemoryJourneyPreviewScreen extends ConsumerStatefulWidget {
  const MemoryJourneyPreviewScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MemoryJourneyPreviewScreen> createState() =>
      _MemoryJourneyPreviewScreenState();
}

class _MemoryJourneyPreviewScreenState
    extends ConsumerState<MemoryJourneyPreviewScreen> {
  @override
  void initState() {
    super.initState();
    // Load memories when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memoryJournalProvider.notifier).loadMemories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final memoryState = ref.watch(memoryJournalProvider);
    final memoryJourneyState = ref.watch(memoryJourneyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Journey'),
        backgroundColor: Colors.pink.shade100,
        foregroundColor: Colors.pink.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade50,
              Colors.pink.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),

                // Preview Button
                _buildPreviewButton(memoryState.memories),
                const SizedBox(height: 24),

                // Recent Journeys
                if (memoryJourneyState.journeys.isNotEmpty) ...[
                  _buildRecentJourneysSection(),
                  const SizedBox(height: 24),
                ],

                // Memories List
                _buildMemoriesList(memoryState.memories),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Love Story',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.pink.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Transform your memories into a beautiful, animated journey',
          style: TextStyle(
            fontSize: 16,
            color: Colors.pink.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewButton(List<MemoryModel> memories) {
    final hasMemories = memories.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 140, // Increased height to accommodate content
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasMemories
              ? [Colors.pink.shade400, Colors.pink.shade600]
              : [Colors.grey.shade300, Colors.grey.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasMemories ? _previewJourney : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16), // Reduced padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Added to prevent overflow
              children: [
                Icon(
                  hasMemories
                      ? Icons.play_circle_filled
                      : Icons.add_circle_outline,
                  size: 36, // Slightly smaller icon
                  color: Colors.white,
                ),
                const SizedBox(height: 6), // Reduced spacing
                Text(
                  hasMemories ? 'Preview Your Journey' : 'Add Memories First',
                  style: const TextStyle(
                    fontSize: 16, // Slightly smaller font
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (hasMemories) ...[
                  const SizedBox(height: 4), // Reduced spacing
                  Text(
                    '${memories.length} memories ready',
                    style: TextStyle(
                      fontSize: 12, // Smaller font
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentJourneysSection() {
    final journeys = ref.watch(journeysListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Journeys',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.pink.shade800,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: journeys.length,
            itemBuilder: (context, index) {
              final journey = journeys[index];
              return _buildJourneyCard(journey);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyCard(MemoryJourneyEntity journey) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openJourney(journey),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journey.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${journey.memories.length} memories',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      size: 16,
                      color: Colors.pink.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'View Journey',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.pink.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemoriesList(List<MemoryModel> memories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Memories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade800,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to add memory screen
                Navigator.pushNamed(context, '/main/add-memory');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Memory'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        memories.isEmpty
            ? _buildEmptyState()
            : Column(
                children: memories.map((memory) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: MemoryCard(
                      memory: memory,
                      onTap: () {
                        // Navigate to memory detail
                        Navigator.pushNamed(
                          context,
                          '/main/memory-detail',
                          arguments: memory,
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.pink.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No memories yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first memory to start creating\nyour beautiful journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.pink.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/main/add-memory');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Memory'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _previewJourney() async {
    final memories = ref.read(memoryJournalProvider).memories;

    if (memories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some memories first'),
        ),
      );
      return;
    }

    // Create a journey from current memories
    await ref.read(memoryJourneyProvider.notifier).createJourney(
          title: 'Our Love Journey',
          subtitle: 'A beautiful story of our memories',
          theme: 'romantic-sunset',
          memories: memories,
        );

    // Get the created journey
    final journey = ref.read(currentJourneyProvider);
    if (journey != null) {
      _openJourney(journey);
    }
  }

  void _openJourney(MemoryJourneyEntity journey) async {
    try {
      // Play journey start feedback
      await FeedbackSystem().playJourneyStart();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteMemoryJourneyVisualizer(
            journey: journey,
            onClose: () => Navigator.pop(context),
            onMemoryTap: (memory) async {
              // Play memory tap feedback
              await FeedbackSystem().playMarkerTap();

              // Navigate to memory detail
              Navigator.pushNamed(
                context,
                '/main/memory-detail',
                arguments: memory,
              );
            },
          ),
        ),
      );
    } catch (e) {
      developer.log('Error opening journey: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening journey: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
