import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/constants.dart';
import '../../domain/entities/event.dart';

part 'event_model.g.dart';

/// Data model for Event entity with JSON serialization.
///
/// This model is used in the data layer for Firebase Firestore
/// and converts to/from the domain Event entity.
@JsonSerializable()
class EventModel {
  final String id;
  final String orgId;
  final String title;
  final String description;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime startAt;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime endAt;

  @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)
  final EventLocation location;

  final int capacity;

  @JsonKey(
    fromJson: _ticketTypesFromJson,
    toJson: _ticketTypesToJson,
    name: 'ticketTypes',
  )
  final List<TicketType> ticketTypes;

  final String? imagePath;
  final String status;

  @JsonKey(fromJson: _agendaFromJson, toJson: _agendaToJson)
  final List<String>? agenda;

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  @JsonKey(
      fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable)
  final DateTime? updatedAt;

  const EventModel({
    required this.id,
    required this.orgId,
    required this.title,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.location,
    required this.capacity,
    required this.ticketTypes,
    this.imagePath,
    required this.status,
    this.agenda,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert from Firestore document.
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Event document data is null');
    }
    // Merge document ID into data
    data['id'] = doc.id;
    return EventModel.fromJson(data);
  }

  /// Convert from JSON.
  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  /// Convert to JSON.
  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  /// Convert from domain entity.
  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      orgId: event.orgId,
      title: event.title,
      description: event.description,
      startAt: event.startAt,
      endAt: event.endAt,
      location: event.location,
      capacity: event.capacity,
      ticketTypes: event.ticketTypes,
      imagePath: event.imagePath,
      status: event.status,
      agenda: event.agenda,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
    );
  }

  /// Convert to domain entity.
  Event toEntity() {
    return Event(
      id: id,
      orgId: orgId,
      title: title,
      description: description,
      startAt: startAt,
      endAt: endAt,
      location: location,
      capacity: capacity,
      ticketTypes: ticketTypes,
      imagePath: imagePath,
      status: status,
      agenda: agenda,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Helper to convert Firestore Timestamp to DateTime.
  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    throw Exception('Invalid timestamp format: $timestamp');
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
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  /// Helper to convert nullable DateTime to Firestore Timestamp.
  static Timestamp? _timestampToJsonNullable(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }

  /// Helper to convert location from JSON.
  static EventLocation _locationFromJson(dynamic json) {
    if (json == null) {
      return const EventLocation(
        lat: 0.0,
        lng: 0.0,
        address: '',
      );
    }
    final map = json as Map<String, dynamic>;
    return EventLocation(
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String? ?? '',
    );
  }

  /// Helper to convert location to JSON.
  static Map<String, dynamic> _locationToJson(EventLocation location) {
    return {
      'lat': location.lat,
      'lng': location.lng,
      'address': location.address,
    };
  }

  /// Helper to convert ticket types from JSON.
  static List<TicketType> _ticketTypesFromJson(dynamic json) {
    if (json == null) return [];
    if (json is! List) return [];
    return json
        .map((item) {
          final map = item as Map<String, dynamic>;
          return TicketType(
            id: map['id'] as String? ?? '',
            title: map['title'] as String? ?? '',
            priceCents: (map['price_cents'] ?? map['priceCents']) as int? ?? 0,
            quantity: map['quantity'] as int? ?? 0,
            salesStart: map['salesStart'] != null
                ? _timestampFromJson(map['salesStart'])
                : null,
            salesEnd: map['salesEnd'] != null
                ? _timestampFromJson(map['salesEnd'])
                : null,
          );
        })
        .toList();
  }

  /// Helper to convert ticket types to JSON.
  static List<Map<String, dynamic>> _ticketTypesToJson(
      List<TicketType> ticketTypes) {
    return ticketTypes.map((ticketType) {
      return {
        'id': ticketType.id,
        'title': ticketType.title,
        'price_cents': ticketType.priceCents,
        'quantity': ticketType.quantity,
        'salesStart': ticketType.salesStart != null
            ? _timestampToJson(ticketType.salesStart!)
            : null,
        'salesEnd': ticketType.salesEnd != null
            ? _timestampToJson(ticketType.salesEnd!)
            : null,
      };
    }).toList();
  }

  /// Helper to convert agenda from JSON.
  static List<String>? _agendaFromJson(dynamic json) {
    if (json == null) return null;
    if (json is! List) return null;
    return json.map((item) => item.toString()).toList();
  }

  /// Helper to convert agenda to JSON.
  static List<String>? _agendaToJson(List<String>? agenda) {
    return agenda;
  }
}
