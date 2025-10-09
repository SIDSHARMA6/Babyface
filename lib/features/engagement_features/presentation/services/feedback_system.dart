import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Haptic and Audio Feedback System
/// Provides tactile and audio feedback for memory journey interactions
class FeedbackSystem {
  static final FeedbackSystem _instance = FeedbackSystem._internal();
  factory FeedbackSystem() => _instance;
  FeedbackSystem._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioEnabled = true;
  bool _isHapticEnabled = true;

  /// Initialize the feedback system
  Future<void> initialize() async {
    // Initialize audio player
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  /// Enable or disable audio feedback
  void setAudioEnabled(bool enabled) {
    _isAudioEnabled = enabled;
  }

  /// Enable or disable haptic feedback
  void setHapticEnabled(bool enabled) {
    _isHapticEnabled = enabled;
  }

  /// Play marker tap feedback
  Future<void> playMarkerTap() async {
    if (!_isHapticEnabled) return;

    HapticFeedback.lightImpact();
    await _playSound('marker_tap');
  }

  /// Play memory reveal feedback
  Future<void> playMemoryReveal() async {
    if (!_isHapticEnabled) return;

    HapticFeedback.mediumImpact();
    await _playSound('memory_reveal');
  }

  /// Play special moment feedback (favorite memories)
  Future<void> playSpecialMoment() async {
    if (!_isHapticEnabled) return;

    HapticFeedback.heavyImpact();
    await _playSound('special_moment');
  }

  /// Play timeline scrub feedback
  Future<void> playTimelineScrub() async {
    if (!_isHapticEnabled) return;

    HapticFeedback.selectionClick();
  }

  /// Play button press feedback
  Future<void> playButtonPress() async {
    if (!_isHapticEnabled) return;

    HapticFeedback.lightImpact();
    await _playSound('button_press');
  }

  /// Play journey start feedback
  Future<void> playJourneyStart() async {
    if (!_isHapticEnabled) return;

    HapticFeedback.mediumImpact();
    await _playSound('journey_start');
  }

  /// Play journey end feedback
  Future<void> playJourneyEnd() async {
    if (!_isHapticEnabled) return;

    HapticFeedback.heavyImpact();
    await _playSound('journey_end');
  }

  /// Play zoom feedback
  Future<void> playZoom() async {
    if (!_isHapticEnabled) return;

    HapticFeedback.selectionClick();
    await _playSound('zoom');
  }

  /// Play error feedback
  Future<void> playError() async {
    if (!_isHapticEnabled) return;

    HapticFeedback.heavyImpact();
    await _playSound('error');
  }

  /// Play success feedback
  Future<void> playSuccess() async {
    if (!_isHapticEnabled) return;

    HapticFeedback.mediumImpact();
    await _playSound('success');
  }

  /// Play ambient background music
  Future<void> playAmbientMusic(String theme) async {
    if (!_isAudioEnabled) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(0.3);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Play theme-specific ambient music
      String audioFile;
      switch (theme) {
        case 'romantic-sunset':
          audioFile = 'romantic_ambient_01.mp3';
          break;
        case 'love-garden':
          audioFile = 'garden_ambient_01.mp3';
          break;
        case 'midnight-romance':
          audioFile = 'midnight_ambient_01.mp3';
          break;
        default:
          audioFile = 'romantic_ambient_01.mp3';
      }

      await _audioPlayer.play(AssetSource('audio/$audioFile'));
    } catch (e) {
      // Silently handle audio errors
      developer.log('Audio playback error: $e');
    }
  }

  /// Stop ambient music
  Future<void> stopAmbientMusic() async {
    await _audioPlayer.stop();
  }

  /// Play memory-specific sound
  Future<void> playMemorySound(String mood) async {
    if (!_isAudioEnabled) return;

    String soundFile;
    switch (mood.toLowerCase()) {
      case 'joyful':
        soundFile = 'joyful_chime.mp3';
        break;
      case 'romantic':
        soundFile = 'romantic_chime.mp3';
        break;
      case 'fun':
        soundFile = 'fun_chime.mp3';
        break;
      case 'sweet':
        soundFile = 'sweet_chime.mp3';
        break;
      case 'emotional':
        soundFile = 'emotional_chime.mp3';
        break;
      case 'excited':
        soundFile = 'excited_chime.mp3';
        break;
      default:
        soundFile = 'default_chime.mp3';
    }

    await _playSound(soundFile);
  }

  /// Play UI interaction sound
  Future<void> playUISound(String action) async {
    if (!_isAudioEnabled) return;

    await _playSound('ui_$action');
  }

  /// Private method to play sound
  Future<void> _playSound(String soundFile) async {
    if (!_isAudioEnabled) return;

    try {
      await _audioPlayer.play(AssetSource('audio/$soundFile'));
    } catch (e) {
      // Silently handle audio errors
      developer.log('Sound playback error: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

/// Feedback Provider for Riverpod
class FeedbackProvider extends StateNotifier<FeedbackSystem> {
  FeedbackProvider() : super(FeedbackSystem()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await state.initialize();
  }

  void setAudioEnabled(bool enabled) {
    state.setAudioEnabled(enabled);
  }

  void setHapticEnabled(bool enabled) {
    state.setHapticEnabled(enabled);
  }

  Future<void> playMarkerTap() async {
    await state.playMarkerTap();
  }

  Future<void> playMemoryReveal() async {
    await state.playMemoryReveal();
  }

  Future<void> playSpecialMoment() async {
    await state.playSpecialMoment();
  }

  Future<void> playTimelineScrub() async {
    await state.playTimelineScrub();
  }

  Future<void> playButtonPress() async {
    await state.playButtonPress();
  }

  Future<void> playJourneyStart() async {
    await state.playJourneyStart();
  }

  Future<void> playJourneyEnd() async {
    await state.playJourneyEnd();
  }

  Future<void> playZoom() async {
    await state.playZoom();
  }

  Future<void> playError() async {
    await state.playError();
  }

  Future<void> playSuccess() async {
    await state.playSuccess();
  }

  Future<void> playAmbientMusic(String theme) async {
    await state.playAmbientMusic(theme);
  }

  Future<void> stopAmbientMusic() async {
    await state.stopAmbientMusic();
  }

  Future<void> playMemorySound(String mood) async {
    await state.playMemorySound(mood);
  }

  Future<void> playUISound(String action) async {
    await state.playUISound(action);
  }
}

/// Feedback Provider
final feedbackProvider =
    StateNotifierProvider<FeedbackProvider, FeedbackSystem>((ref) {
  return FeedbackProvider();
});

/// Feedback Mixin for easy integration
mixin FeedbackMixin<T extends StatefulWidget> on State<T> {
  FeedbackSystem get feedback => FeedbackSystem();

  Future<void> playMarkerTap() async {
    await feedback.playMarkerTap();
  }

  Future<void> playMemoryReveal() async {
    await feedback.playMemoryReveal();
  }

  Future<void> playSpecialMoment() async {
    await feedback.playSpecialMoment();
  }

  Future<void> playTimelineScrub() async {
    await feedback.playTimelineScrub();
  }

  Future<void> playButtonPress() async {
    await feedback.playButtonPress();
  }

  Future<void> playJourneyStart() async {
    await feedback.playJourneyStart();
  }

  Future<void> playJourneyEnd() async {
    await feedback.playJourneyEnd();
  }

  Future<void> playZoom() async {
    await feedback.playZoom();
  }

  Future<void> playError() async {
    await feedback.playError();
  }

  Future<void> playSuccess() async {
    await feedback.playSuccess();
  }

  Future<void> playAmbientMusic(String theme) async {
    await feedback.playAmbientMusic(theme);
  }

  Future<void> stopAmbientMusic() async {
    await feedback.stopAmbientMusic();
  }

  Future<void> playMemorySound(String mood) async {
    await feedback.playMemorySound(mood);
  }

  Future<void> playUISound(String action) async {
    await feedback.playUISound(action);
  }
}
