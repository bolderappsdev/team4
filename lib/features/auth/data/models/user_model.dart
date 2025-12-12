import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:leadright/features/auth/domain/entities/user.dart';

part 'user_model.g.dart';

/// Data model for User entity with JSON serialization.
/// Comment
/// This model is used in the data layer for Firebase Firestore
/// and converts to/from the domain User entity.
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final List<String> roles;
  final String? organizationId;
  final String? stripeAccountId;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  @JsonKey(
      fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable)
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.roles = const ['attendee'],
    this.organizationId,
    this.stripeAccountId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert from JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert to JSON.
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convert from domain entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      roles: user.roles,
      organizationId: user.organizationId,
      stripeAccountId: user.stripeAccountId,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// Convert to domain entity.
  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      roles: roles,
      organizationId: organizationId,
      stripeAccountId: stripeAccountId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Helper to convert Firestore Timestamp to DateTime.
  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return DateTime.parse(timestamp as String);
  }

  /// Helper to convert DateTime to Firestore Timestamp.
  static Timestamp _timestampToJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }

  /// Helper to convert nullable Firestore Timestamp to DateTime.
  static DateTime? _timestampFromJsonNullable(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return DateTime.parse(timestamp as String);
  }

  /// Helper to convert nullable DateTime to Firestore Timestamp.
  static Timestamp? _timestampToJsonNullable(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }
}
