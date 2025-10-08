/// User model for authentication
class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? partnerName;
  final String? bondName;
  final bool isComplete;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.firstName,
    this.lastName,
    this.gender,
    this.partnerName,
    this.bondName,
    required this.isComplete,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? firstName,
    String? lastName,
    String? gender,
    String? partnerName,
    String? bondName,
    bool? isComplete,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      partnerName: partnerName ?? this.partnerName,
      bondName: bondName ?? this.bondName,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'partnerName': partnerName,
      'bondName': bondName,
      'isComplete': isComplete,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      gender: map['gender'],
      partnerName: map['partnerName'],
      bondName: map['bondName'],
      isComplete: map['isComplete'] ?? false,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, gender: $gender, partnerName: $partnerName, bondName: $bondName, isComplete: $isComplete)';
  }
}
