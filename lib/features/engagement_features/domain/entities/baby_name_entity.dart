import 'package:equatable/equatable.dart';

/// Baby name entity
/// Follows master plan clean architecture
class BabyNameEntity extends Equatable {
  final String id;
  final String name;
  final String gender;
  final String origin;
  final String meaning;
  final double popularity;
  final List<String> similarNames;
  final DateTime createdAt;

  const BabyNameEntity({
    required this.id,
    required this.name,
    required this.gender,
    required this.origin,
    required this.meaning,
    required this.popularity,
    required this.similarNames,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        gender,
        origin,
        meaning,
        popularity,
        similarNames,
        createdAt,
      ];

  BabyNameEntity copyWith({
    String? id,
    String? name,
    String? gender,
    String? origin,
    String? meaning,
    double? popularity,
    List<String>? similarNames,
    DateTime? createdAt,
  }) {
    return BabyNameEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      origin: origin ?? this.origin,
      meaning: meaning ?? this.meaning,
      popularity: popularity ?? this.popularity,
      similarNames: similarNames ?? this.similarNames,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Baby name generation request
class BabyNameRequest extends Equatable {
  final String? gender;
  final String? origin;
  final String? style;
  final int count;
  final bool includeMeaning;

  const BabyNameRequest({
    this.gender,
    this.origin,
    this.style,
    this.count = 10,
    this.includeMeaning = true,
  });

  @override
  List<Object?> get props => [gender, origin, style, count, includeMeaning];
}
