import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/event_model.dart';

/// Remote data source for events operations using Firebase Firestore.
abstract class EventRemoteDataSource {
  /// Get upcoming published events.
  Stream<List<EventModel>> getUpcomingEvents();

  /// Get event by ID.
  Future<EventModel> getEventById(String eventId);

  /// Get events by organization ID.
  Stream<List<EventModel>> getEventsByOrganization(String orgId);

  /// Create a new event.
  Future<EventModel> createEvent(EventModel event);

  /// Get events that a user is attending (via tickets).
  Stream<List<EventModel>> getEventsByUserAttendance(String userId);
}

@LazySingleton(as: EventRemoteDataSource)
class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final FirebaseFirestore _firestore;

  EventRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<EventModel>> getUpcomingEvents() {
    try {
      final now = DateTime.now();
      return _firestore
          .collection(AppConstants.eventsCollection)
          .where('status', isEqualTo: AppConstants.eventStatusPublished)
          .where('startAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('startAt', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw ServerException('Failed to fetch upcoming events: ${e.toString()}');
    }
  }

  @override
  Future<EventModel> getEventById(String eventId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .get();

      if (!doc.exists) {
        throw NotFoundException('Event not found: $eventId');
      }

      return EventModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw ServerException('Failed to fetch event: ${e.toString()}');
    }
  }

  @override
  Stream<List<EventModel>> getEventsByOrganization(String orgId) {
    try {
      return _firestore
          .collection(AppConstants.eventsCollection)
          .where('orgId', isEqualTo: orgId)
          .orderBy('startAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw ServerException(
          'Failed to fetch organization events: ${e.toString()}');
    }
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    try {
      final eventJson = event.toJson();
      // Remove id from JSON as Firestore will generate it
      eventJson.remove('id');
      
      final docRef = await _firestore
          .collection(AppConstants.eventsCollection)
          .add(eventJson);

      // Fetch the created document to return with the generated ID
      final doc = await docRef.get();
      return EventModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to create event: ${e.toString()}');
    }
  }

  @override
  Stream<List<EventModel>> getEventsByUserAttendance(String userId) {
    try {
      // First, get all tickets for the user
      return _firestore
          .collection(AppConstants.ticketsCollection)
          .where('ownerUserId', isEqualTo: userId)
          .snapshots()
          .asyncMap((ticketsSnapshot) async {
        if (ticketsSnapshot.docs.isEmpty) {
          return <EventModel>[];
        }

        // Get unique event IDs from tickets
        final eventIds = ticketsSnapshot.docs
            .map((doc) => doc.data()['eventId'] as String?)
            .where((id) => id != null)
            .toSet()
            .toList();

        if (eventIds.isEmpty) {
          return <EventModel>[];
        }

        // Fetch events for these event IDs
        // Note: Firestore 'in' query limit is 10, so we batch if needed
        final events = <EventModel>[];
        for (var i = 0; i < eventIds.length; i += 10) {
          final batch = eventIds.skip(i).take(10).toList();
          final eventsSnapshot = await _firestore
              .collection(AppConstants.eventsCollection)
              .where(FieldPath.documentId, whereIn: batch)
              .get();
          
          events.addAll(
            eventsSnapshot.docs
                .map((doc) => EventModel.fromFirestore(doc))
                .toList(),
          );
        }

        // Sort by start date
        events.sort((a, b) => a.startAt.compareTo(b.startAt));
        
        return events;
      });
    } catch (e) {
      throw ServerException(
          'Failed to fetch user attendance events: ${e.toString()}');
    }
  }
}
