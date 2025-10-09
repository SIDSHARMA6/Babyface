import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'avatar_data.dart';
import 'baby_result.dart';
import 'user_profile.dart';
import '../../features/quiz/domain/models/quiz_models.dart';
import '../../features/engagement_features/data/models/memory_journey_model.dart';
import '../../features/engagement_features/data/models/memory_model.dart';

/// Centralized Hive adapter registration
class HiveAdapters {
  static Future<void> registerAdapters() async {
    // Register existing adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AvatarDataAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BabyResultAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserProfileAdapter());
    }

    // Register quiz model adapters
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(QuizQuestionAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(QuizLevelAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(QuizCategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(UserQuizProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(QuizSessionAdapter());
    }

    // Register memory journey adapters
    if (!Hive.isAdapterRegistered(30)) {
      Hive.registerAdapter(MemoryJourneyModelAdapter());
    }
    if (!Hive.isAdapterRegistered(31)) {
      Hive.registerAdapter(MemoryJourneySettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(32)) {
      Hive.registerAdapter(MemoryJourneyExportSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(33)) {
      Hive.registerAdapter(MemoryJourneyThemeAdapter());
    }
    if (!Hive.isAdapterRegistered(34)) {
      Hive.registerAdapter(MemoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(35)) {
      Hive.registerAdapter(MemoryMoodAdapter());
    }

    // Register enum adapters
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(QuizCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(QuestionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(DifficultyLevelAdapter());
    }
  }
}

// Enum adapters for quiz models
class QuizCategoryAdapter extends TypeAdapter<QuizCategory> {
  @override
  final int typeId = 20;

  @override
  QuizCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuizCategory.babyGame;
      case 1:
        return QuizCategory.coupleGame;
      case 2:
        return QuizCategory.partingGame;
      case 3:
        return QuizCategory.couplesGoals;
      case 4:
        return QuizCategory.knowEachOther;
      default:
        return QuizCategory.babyGame;
    }
  }

  @override
  void write(BinaryWriter writer, QuizCategory obj) {
    switch (obj) {
      case QuizCategory.babyGame:
        writer.writeByte(0);
        break;
      case QuizCategory.coupleGame:
        writer.writeByte(1);
        break;
      case QuizCategory.partingGame:
        writer.writeByte(2);
        break;
      case QuizCategory.couplesGoals:
        writer.writeByte(3);
        break;
      case QuizCategory.knowEachOther:
        writer.writeByte(4);
        break;
    }
  }
}

class QuestionTypeAdapter extends TypeAdapter<QuestionType> {
  @override
  final int typeId = 21;

  @override
  QuestionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuestionType.multipleChoice;
      case 1:
        return QuestionType.puzzle;
      case 2:
        return QuestionType.dragDrop;
      case 3:
        return QuestionType.matching;
      case 4:
        return QuestionType.emoji;
      default:
        return QuestionType.multipleChoice;
    }
  }

  @override
  void write(BinaryWriter writer, QuestionType obj) {
    switch (obj) {
      case QuestionType.multipleChoice:
        writer.writeByte(0);
        break;
      case QuestionType.puzzle:
        writer.writeByte(1);
        break;
      case QuestionType.dragDrop:
        writer.writeByte(2);
        break;
      case QuestionType.matching:
        writer.writeByte(3);
        break;
      case QuestionType.emoji:
        writer.writeByte(4);
        break;
    }
  }
}

class DifficultyLevelAdapter extends TypeAdapter<DifficultyLevel> {
  @override
  final int typeId = 22;

  @override
  DifficultyLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DifficultyLevel.easy;
      case 1:
        return DifficultyLevel.medium;
      case 2:
        return DifficultyLevel.hard;
      case 3:
        return DifficultyLevel.expert;
      default:
        return DifficultyLevel.easy;
    }
  }

  @override
  void write(BinaryWriter writer, DifficultyLevel obj) {
    switch (obj) {
      case DifficultyLevel.easy:
        writer.writeByte(0);
        break;
      case DifficultyLevel.medium:
        writer.writeByte(1);
        break;
      case DifficultyLevel.hard:
        writer.writeByte(2);
        break;
      case DifficultyLevel.expert:
        writer.writeByte(3);
        break;
    }
  }
}

// Model adapters - these would normally be generated by hive_generator
// For now, we'll create simplified versions

class QuizQuestionAdapter extends TypeAdapter<QuizQuestion> {
  @override
  final int typeId = 10;

  @override
  QuizQuestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizQuestion(
      id: fields[0] as String,
      question: fields[1] as String,
      options: (fields[2] as List).cast<String>(),
      correctAnswerIndex: fields[3] as int,
      type: fields[4] as QuestionType,
      explanation: fields[5] as String?,
      imageUrl: fields[6] as String?,
      puzzleData: fields[7] as Map<String, dynamic>?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizQuestion obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.options)
      ..writeByte(3)
      ..write(obj.correctAnswerIndex)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.explanation)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.puzzleData);
  }
}

class QuizLevelAdapter extends TypeAdapter<QuizLevel> {
  @override
  final int typeId = 11;

  @override
  QuizLevel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizLevel(
      id: fields[0] as String,
      levelNumber: fields[1] as int,
      title: fields[2] as String,
      description: fields[3] as String,
      difficulty: fields[4] as DifficultyLevel,
      questions: (fields[5] as List).cast<QuizQuestion>(),
      requiredScore: fields[6] as int? ?? 5,
      rewards: (fields[7] as List?)?.cast<String>() ?? [],
      isUnlocked: fields[8] as bool? ?? false,
      completedAt: fields[9] as DateTime?,
      userScore: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizLevel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.levelNumber)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.questions)
      ..writeByte(6)
      ..write(obj.requiredScore)
      ..writeByte(7)
      ..write(obj.rewards)
      ..writeByte(8)
      ..write(obj.isUnlocked)
      ..writeByte(9)
      ..write(obj.completedAt)
      ..writeByte(10)
      ..write(obj.userScore);
  }
}

class QuizCategoryModelAdapter extends TypeAdapter<QuizCategoryModel> {
  @override
  final int typeId = 12;

  @override
  QuizCategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizCategoryModel(
      id: fields[0] as String,
      category: fields[1] as QuizCategory,
      title: fields[2] as String,
      description: fields[3] as String,
      iconPath: fields[4] as String,
      colorValue: fields[5] as int,
      levels: (fields[6] as List).cast<QuizLevel>(),
      totalLevels: fields[7] as int? ?? 0,
      completedLevels: fields[8] as int? ?? 0,
      totalScore: fields[9] as int? ?? 0,
      lastPlayedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizCategoryModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.iconPath)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.levels)
      ..writeByte(7)
      ..write(obj.totalLevels)
      ..writeByte(8)
      ..write(obj.completedLevels)
      ..writeByte(9)
      ..write(obj.totalScore)
      ..writeByte(10)
      ..write(obj.lastPlayedAt);
  }
}

class UserQuizProgressAdapter extends TypeAdapter<UserQuizProgress> {
  @override
  final int typeId = 13;

  @override
  UserQuizProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserQuizProgress(
      userId: fields[0] as String,
      categoryScores: (fields[1] as Map?)?.cast<String, int>() ?? {},
      categoryLevelsCompleted: (fields[2] as Map?)?.cast<String, int>() ?? {},
      earnedBadges: (fields[3] as List?)?.cast<String>() ?? [],
      totalQuizzesCompleted: fields[4] as int? ?? 0,
      totalScore: fields[5] as int? ?? 0,
      lastPlayedAt: fields[6] as DateTime?,
      categoryLastPlayed: (fields[7] as Map?)?.cast<String, DateTime>() ?? {},
    );
  }

  @override
  void write(BinaryWriter writer, UserQuizProgress obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.categoryScores)
      ..writeByte(2)
      ..write(obj.categoryLevelsCompleted)
      ..writeByte(3)
      ..write(obj.earnedBadges)
      ..writeByte(4)
      ..write(obj.totalQuizzesCompleted)
      ..writeByte(5)
      ..write(obj.totalScore)
      ..writeByte(6)
      ..write(obj.lastPlayedAt)
      ..writeByte(7)
      ..write(obj.categoryLastPlayed);
  }
}

class QuizSessionAdapter extends TypeAdapter<QuizSession> {
  @override
  final int typeId = 14;

  @override
  QuizSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizSession(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      levelId: fields[2] as String,
      currentQuestionIndex: fields[3] as int? ?? 0,
      userAnswers: (fields[4] as List?)?.cast<int>() ?? [],
      score: fields[5] as int? ?? 0,
      startedAt: fields[6] as DateTime,
      completedAt: fields[7] as DateTime?,
      isCompleted: fields[8] as bool? ?? false,
      sessionData: fields[9] as Map<String, dynamic>?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizSession obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.levelId)
      ..writeByte(3)
      ..write(obj.currentQuestionIndex)
      ..writeByte(4)
      ..write(obj.userAnswers)
      ..writeByte(5)
      ..write(obj.score)
      ..writeByte(6)
      ..write(obj.startedAt)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.sessionData);
  }
}

// Placeholder adapters for existing models (these should already exist)
class AvatarDataAdapter extends TypeAdapter<AvatarData> {
  @override
  final int typeId = 0;

  @override
  AvatarData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AvatarData(
      id: fields[0] as String,
      imagePath: fields[1] as String?,
      faceDetected: fields[2] as bool? ?? false,
      faceConfidence: fields[3] as double? ?? 0.0,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime?,
      uploadedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AvatarData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.faceDetected)
      ..writeByte(3)
      ..write(obj.faceConfidence)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.uploadedAt);
  }
}

class BabyResultAdapter extends TypeAdapter<BabyResult> {
  @override
  final int typeId = 1;

  @override
  BabyResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BabyResult(
      id: fields[0] as String,
      babyImagePath: fields[1] as String?,
      maleMatchPercentage: fields[2] as int,
      femaleMatchPercentage: fields[3] as int,
      createdAt: fields[4] as DateTime,
      isProcessing: fields[5] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, BabyResult obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyImagePath)
      ..writeByte(2)
      ..write(obj.maleMatchPercentage)
      ..writeByte(3)
      ..write(obj.femaleMatchPercentage)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isProcessing);
  }
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 2;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String,
      name: fields[1] as String?,
      email: fields[2] as String?,
      malePhotoPath: fields[3] as String?,
      femalePhotoPath: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.malePhotoPath)
      ..writeByte(4)
      ..write(obj.femalePhotoPath)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }
}

// Memory Journey Adapters
class MemoryJourneyModelAdapter extends TypeAdapter<MemoryJourneyModel> {
  @override
  final int typeId = 30;

  @override
  MemoryJourneyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryJourneyModel(
      journeyId: fields[0] as String,
      title: fields[1] as String,
      subtitle: fields[2] as String,
      theme: fields[3] as String,
      createdAt: fields[4] as DateTime,
      lastModified: fields[5] as DateTime,
      memories: (fields[6] as List).cast<MemoryModel>(),
      settings: fields[7] as MemoryJourneySettings,
      exportSettings: fields[8] as MemoryJourneyExportSettings,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryJourneyModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.journeyId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.theme)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.lastModified)
      ..writeByte(6)
      ..write(obj.memories)
      ..writeByte(7)
      ..write(obj.settings)
      ..writeByte(8)
      ..write(obj.exportSettings);
  }
}

class MemoryJourneySettingsAdapter extends TypeAdapter<MemoryJourneySettings> {
  @override
  final int typeId = 31;

  @override
  MemoryJourneySettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryJourneySettings(
      animationSpeed: fields[0] as double,
      showLabels: fields[1] as bool,
      showDates: fields[2] as bool,
      showEmotions: fields[3] as bool,
      autoPlay: fields[4] as bool,
      loopAnimation: fields[5] as bool,
      backgroundMusic: fields[6] as String?,
      particleEffects: fields[7] as bool,
      depthOfField: fields[8] as bool,
      theme: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryJourneySettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.animationSpeed)
      ..writeByte(1)
      ..write(obj.showLabels)
      ..writeByte(2)
      ..write(obj.showDates)
      ..writeByte(3)
      ..write(obj.showEmotions)
      ..writeByte(4)
      ..write(obj.autoPlay)
      ..writeByte(5)
      ..write(obj.loopAnimation)
      ..writeByte(6)
      ..write(obj.backgroundMusic)
      ..writeByte(7)
      ..write(obj.particleEffects)
      ..writeByte(8)
      ..write(obj.depthOfField)
      ..writeByte(9)
      ..write(obj.theme);
  }
}

class MemoryJourneyExportSettingsAdapter
    extends TypeAdapter<MemoryJourneyExportSettings> {
  @override
  final int typeId = 32;

  @override
  MemoryJourneyExportSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryJourneyExportSettings(
      videoQuality: fields[0] as String,
      includeAudio: fields[1] as bool,
      watermark: fields[2] as bool,
      duration: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryJourneyExportSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.videoQuality)
      ..writeByte(1)
      ..write(obj.includeAudio)
      ..writeByte(2)
      ..write(obj.watermark)
      ..writeByte(3)
      ..write(obj.duration);
  }
}

class MemoryJourneyThemeAdapter extends TypeAdapter<MemoryJourneyTheme> {
  @override
  final int typeId = 33;

  @override
  MemoryJourneyTheme read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryJourneyTheme(
      name: fields[0] as String,
      displayName: fields[1] as String,
      primaryColor: fields[2] as Color,
      secondaryColor: fields[3] as Color,
      accentColor: fields[4] as Color,
      backgroundColor: fields[5] as Color,
      textColor: fields[6] as Color,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryJourneyTheme obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.primaryColor)
      ..writeByte(3)
      ..write(obj.secondaryColor)
      ..writeByte(4)
      ..write(obj.accentColor)
      ..writeByte(5)
      ..write(obj.backgroundColor)
      ..writeByte(6)
      ..write(obj.textColor);
  }
}

class MemoryModelAdapter extends TypeAdapter<MemoryModel> {
  @override
  final int typeId = 34;

  @override
  MemoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      emoji: fields[3] as String,
      photoPath: fields[4] as String?,
      date: fields[5] as String,
      voicePath: fields[6] as String?,
      mood: fields[7] as String,
      positionIndex: fields[8] as int,
      timestamp: fields[9] as int,
      isFavorite: fields[10] as bool,
      location: fields[11] as String?,
      tags: (fields[12] as List).cast<String>(),
      roadPosition: fields[13] as Offset?,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.emoji)
      ..writeByte(4)
      ..write(obj.photoPath)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.voicePath)
      ..writeByte(7)
      ..write(obj.mood)
      ..writeByte(8)
      ..write(obj.positionIndex)
      ..writeByte(9)
      ..write(obj.timestamp)
      ..writeByte(10)
      ..write(obj.isFavorite)
      ..writeByte(11)
      ..write(obj.location)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.roadPosition);
  }
}

class MemoryMoodAdapter extends TypeAdapter<MemoryMood> {
  @override
  final int typeId = 35;

  @override
  MemoryMood read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MemoryMood.joyful;
      case 1:
        return MemoryMood.sweet;
      case 2:
        return MemoryMood.emotional;
      case 3:
        return MemoryMood.romantic;
      case 4:
        return MemoryMood.fun;
      case 5:
        return MemoryMood.excited;
      default:
        return MemoryMood.joyful;
    }
  }

  @override
  void write(BinaryWriter writer, MemoryMood obj) {
    switch (obj) {
      case MemoryMood.joyful:
        writer.writeByte(0);
        break;
      case MemoryMood.sweet:
        writer.writeByte(1);
        break;
      case MemoryMood.emotional:
        writer.writeByte(2);
        break;
      case MemoryMood.romantic:
        writer.writeByte(3);
        break;
      case MemoryMood.fun:
        writer.writeByte(4);
        break;
      case MemoryMood.excited:
        writer.writeByte(5);
        break;
    }
  }
}
