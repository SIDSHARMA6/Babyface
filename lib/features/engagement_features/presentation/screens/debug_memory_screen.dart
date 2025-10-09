import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/services/hive_service.dart';
import '../../../../shared/services/firebase_user_service.dart';
import '../providers/memory_journal_provider.dart';
import '../../data/models/memory_model.dart';

/// Debug Memory Screen for testing persistence
class DebugMemoryScreen extends ConsumerStatefulWidget {
  const DebugMemoryScreen({super.key});

  @override
  ConsumerState<DebugMemoryScreen> createState() => _DebugMemoryScreenState();
}

class _DebugMemoryScreenState extends ConsumerState<DebugMemoryScreen> {
  final HiveService _hiveService = HiveService();
  final FirebaseUserService _firebaseService = FirebaseUserService();
  String _debugInfo = '';

  @override
  Widget build(BuildContext context) {
    final memoryState = ref.watch(memoryJournalProvider);
    final memoryNotifier = ref.read(memoryJournalProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Memory Persistence', style: BabyFont.headingM),
        backgroundColor: AppTheme.primaryPink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Memory Count: ${memoryState.memories.length}',
                style: BabyFont.headingS),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _testHivePersistence(),
                  child: Text('Test Hive'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _testFirebasePersistence(),
                  child: Text('Test Firebase'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _addTestMemory(memoryNotifier),
                  child: Text('Add Test Memory'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => memoryNotifier.loadMemories(),
                  child: Text('Reload Memories'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _clearAllData(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  Text('Clear All Data', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            Text('Debug Info:', style: BabyFont.headingS),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_debugInfo, style: BabyFont.bodyS),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testHivePersistence() async {
    try {
      setState(() {
        _debugInfo = 'Testing Hive persistence...\n';
      });

      // Check if memory box exists
      final box = _hiveService.getBox('memory_box');
      _addDebugInfo('Memory box exists: ${box != null}');

      if (box != null) {
        _addDebugInfo('Memory box length: ${box.length}');
        _addDebugInfo('Memory box keys: ${box.keys.toList()}');
      }

      // Get all memories from Hive
      final memories = _hiveService.getAll('memory_box');
      _addDebugInfo('Memories in Hive: ${memories.length}');

      for (final entry in memories.entries) {
        _addDebugInfo('Memory ID: ${entry.key}');
        if (entry.value is Map) {
          final memoryData = entry.value as Map<String, dynamic>;
          _addDebugInfo('  Title: ${memoryData['title']}');
          _addDebugInfo('  Timestamp: ${memoryData['timestamp']}');
        }
      }
    } catch (e) {
      _addDebugInfo('Hive test error: $e');
    }
  }

  void _testFirebasePersistence() async {
    try {
      setState(() {
        _debugInfo += '\nTesting Firebase persistence...\n';
      });

      _addDebugInfo('User signed in: ${_firebaseService.isSignedIn}');

      if (_firebaseService.isSignedIn) {
        final currentUser = _firebaseService.currentUser;
        _addDebugInfo('User ID: ${currentUser?.uid}');

        final memories = await _firebaseService.getMemories(currentUser!.uid);
        _addDebugInfo('Memories in Firebase: ${memories.length}');

        for (final memory in memories) {
          _addDebugInfo(
              'Firebase Memory: ${memory['title']} (${memory['id']})');
        }
      } else {
        _addDebugInfo('User not signed in - Firebase test skipped');
      }
    } catch (e) {
      _addDebugInfo('Firebase test error: $e');
    }
  }

  void _addTestMemory(MemoryJournalNotifier notifier) async {
    try {
      _addDebugInfo('\nAdding test memory...');

      await notifier.addMemory(
        title: 'Test Memory ${DateTime.now().millisecondsSinceEpoch}',
        description: 'This is a test memory to verify persistence',
        emoji: '🧪',
        mood: 'joyful',
        tags: ['test', 'debug'],
      );

      _addDebugInfo('Test memory added successfully');

      // Wait a bit and then check persistence
      await Future.delayed(Duration(seconds: 1));
      // await _testHivePersistence();
    } catch (e) {
      _addDebugInfo('Add test memory error: $e');
    }
  }

  void _clearAllData() async {
    try {
      _addDebugInfo('\nClearing all data...');

      await _hiveService.clear('memory_box');
      _addDebugInfo('Hive data cleared');

      final memoryNotifier = ref.read(memoryJournalProvider.notifier);
      await memoryNotifier.loadMemories();
      _addDebugInfo('Memory state refreshed');
    } catch (e) {
      _addDebugInfo('Clear data error: $e');
    }
  }

  void _addDebugInfo(String info) {
    setState(() {
      _debugInfo += '$info\n';
    });
  }
}
