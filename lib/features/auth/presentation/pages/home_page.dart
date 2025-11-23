import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:leadright/di/injection_container.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/events/domain/entities/event.dart';
import 'package:leadright/features/events/presentation/bloc/events_bloc.dart';
import 'package:leadright/features/events/presentation/pages/attendee_event_details_page.dart';
import 'package:leadright/features/events/presentation/widgets/event_card.dart';

/// Home page for attendees displaying upcoming events.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMapView = false;
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Set<Marker> _buildMarkers(BuildContext context, List<Event> events) {
    return events.map((event) {
      return Marker(
        markerId: MarkerId(event.id),
        position: LatLng(event.location.lat, event.location.lng),
        infoWindow: InfoWindow(
          title: event.title,
          snippet: event.location.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
        onTap: () {
          _showEventBottomSheet(context, event);
        },
      );
    }).toSet();
  }

  void _fitBounds(List<Event> events) {
    if (events.isEmpty || _mapController == null) return;

    double minLat = events.first.location.lat;
    double maxLat = events.first.location.lat;
    double minLng = events.first.location.lng;
    double maxLng = events.first.location.lng;

    for (var event in events) {
      final lat = event.location.lat;
      final lng = event.location.lng;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0,
      ),
    );
  }

  void _showEventBottomSheet(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventBottomSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = getIt<EventsBloc>();
        // Dispatch event to fetch upcoming events when bloc is created
        bloc.add(const FetchUpcomingEvents());
        return bloc;
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return SafeArea(
              child: Column(
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Logo and View Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo and App Name
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFF1E3A8A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(14380469),
                                        ),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.event,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'LeadRight',
                                    style: TextStyle(
                                      color: Color(0xFF1E3A8A),
                                      fontSize: 24,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.31,
                                    ),
                                  ),
                                ],
                              ),
                              // View Toggle Switch
                              Container(
                                height: 44,
                                padding: const EdgeInsets.all(4),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFF6F6F6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(46),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // List View Button
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isMapView = false;
                                        });
                                      },
                                      child: Container(
                                        width: 36,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: ShapeDecoration(
                                          color: _isMapView
                                              ? Colors.transparent
                                              : const Color(0xFF1E3A8A),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(40),
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.list,
                                          color: _isMapView
                                              ? const Color(0xFF667084)
                                              : Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    // Map View Button
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isMapView = true;
                                        });
                                      },
                                      child: Container(
                                        width: 36,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: ShapeDecoration(
                                          color: _isMapView
                                              ? const Color(0xFF1E3A8A)
                                              : Colors.transparent,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(40),
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.map,
                                          color: _isMapView
                                              ? Colors.white
                                              : const Color(0xFF667084),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Search and Event Theme Row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search Container
                              SizedBox(
                                width: 208,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF6F6F6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search,
                                        size: 16,
                                        color: Color(0xFF667084),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Search',
                                          style: TextStyle(
                                            color: Color(0xFF667084),
                                            fontSize: 14,
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.w400,
                                            height: 1.43,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Event Theme Filter
                              Expanded(
                                child: Container(
                                  height: 44,
                                  padding: const EdgeInsets.all(12),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF6F6F6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Event Theme',
                                        style: TextStyle(
                                          color: Color(0xFF667084),
                                          fontSize: 12,
                                          fontFamily: 'Quicksand',
                                          fontWeight: FontWeight.w500,
                                          height: 1.50,
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: Color(0xFF667084),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Events List or Map Section
                    Expanded(
                      child: BlocBuilder<EventsBloc, EventsState>(
                        builder: (context, eventsState) {
                          if (eventsState is EventsLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (eventsState is EventsError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    eventsState.message,
                                    style: const TextStyle(
                                      color: Color(0xFF0F1728),
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<EventsBloc>()
                                          .add(const FetchUpcomingEvents());
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          } else if (eventsState is EventsLoaded) {
                            if (eventsState.events.isEmpty) {
                              return Center(
                                child: Text(
                                  _isMapView
                                      ? 'No events to display on map'
                                      : 'No upcoming events',
                                  style: const TextStyle(
                                    color: Color(0xFF0F1728),
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }

                            // Show Map View
                            if (_isMapView) {
                              // Filter events with valid coordinates
                              final validEvents = eventsState.events
                                  .where((e) =>
                                      e.location.lat != 0.0 &&
                                      e.location.lng != 0.0)
                                  .toList();

                              if (validEvents.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No events with valid locations',
                                    style: TextStyle(
                                      color: Color(0xFF0F1728),
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }

                              // Calculate center point
                              double centerLat = validEvents
                                  .map((e) => e.location.lat)
                                  .reduce((a, b) => a + b) /
                                  validEvents.length;
                              double centerLng = validEvents
                                  .map((e) => e.location.lng)
                                  .reduce((a, b) => a + b) /
                                  validEvents.length;

                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  top: 12,
                                  right: 16,
                                  bottom: 16,
                                ),
                                child: Container(
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Stack(
                                      children: [
                                        GoogleMap(
                                          onMapCreated: (controller) {
                                            _onMapCreated(controller);
                                            // Fit bounds after map is created
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              _fitBounds(validEvents);
                                            });
                                          },
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(centerLat, centerLng),
                                            zoom: 12,
                                          ),
                                          markers: _buildMarkers(context, validEvents),
                                          mapType: MapType.normal,
                                          myLocationButtonEnabled: false,
                                          zoomControlsEnabled: false,
                                        ),
                                        // Floating action button for location
                                        Positioned(
                                          right: 14,
                                          bottom: 14,
                                          child: Container(
                                            width: 48,
                                            height: 48,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFF1E3A8A),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              shadows: const [
                                                BoxShadow(
                                                  color: Color(0x19000000),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.my_location,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                // Fit bounds when location button is pressed
                                                if (_mapController != null) {
                                                  _fitBounds(validEvents);
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Show List View
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Upcoming Events',
                                    style: TextStyle(
                                      color: Color(0xFF0F1728),
                                      fontSize: 20,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.50,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: eventsState.events.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final event = eventsState.events[index];
                                        return EventCard(
                                          event: event,
                                          onViewDetails: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AttendeeEventDetailsPage(
                                                  event: event,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      );
  }
}


class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: const Color(0xFFF6F6F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667084),
              fontSize: 12,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: Color(0xFF667084),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet widget for displaying event details.
class _EventBottomSheet extends StatelessWidget {
  final Event event;

  const _EventBottomSheet({required this.event});

  /// Get badge color based on event type.
  Color _getBadgeColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'town hall':
        return const Color(0xFFDBEAFE);
      case 'forum':
        return const Color(0xFFFFEDD4);
      case 'debate':
        return const Color(0xFFF3E8FF);
      default:
        return const Color(0xFFDBEAFE);
    }
  }

  /// Get badge border color based on event type.
  Color _getBadgeBorderColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'town hall':
        return const Color(0xFFBDDAFF);
      case 'forum':
        return const Color(0xFFFFD6A7);
      case 'debate':
        return const Color(0xFFE9D4FF);
      default:
        return const Color(0xFFBDDAFF);
    }
  }

  /// Get badge text color based on event type.
  Color _getBadgeTextColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'town hall':
        return const Color(0xFF193BB8);
      case 'forum':
        return const Color(0xFF9F2D00);
      case 'debate':
        return const Color(0xFF6D10B0);
      default:
        return const Color(0xFF193BB8);
    }
  }

  /// Get image URL for event.
  String _getImageUrl() {
    if (event.imagePath != null && event.imagePath!.isNotEmpty) {
      // TODO: Get from Firebase Storage URL
      // For now, return placeholder
      return 'https://placehold.co/341x192';
    }
    return 'https://placehold.co/341x192';
  }

  @override
  Widget build(BuildContext context) {
    final eventType = event.eventType;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final startTime = timeFormat.format(event.startAt);
    final endTime = timeFormat.format(event.endAt);

    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 375 ? 359.0 : screenWidth - 16;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 16,
        left: 8,
        right: 8,
        bottom: 32,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 4,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEAECF0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(55),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: contentWidth,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFCFD4DC),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 192,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: _getImageUrl(),
                              width: double.infinity,
                              height: 192,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFFF6F6F6),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFFF6F6F6),
                                child: const Icon(Icons.error),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: _getBadgeColor(eventType),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: _getBadgeBorderColor(eventType),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  eventType,
                                  style: TextStyle(
                                    color: _getBadgeTextColor(eventType),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    height: 1.33,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      color: Color(0xFF0A0A0A),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      height: 1.50,
                                      letterSpacing: -0.31,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: const BoxDecoration(),
                                        child: const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        dateFormat.format(event.startAt),
                                        style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                          letterSpacing: -0.15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Time
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: const BoxDecoration(),
                                        child: const Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$startTime - $endTime',
                                        style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                          letterSpacing: -0.15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Organizer
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: const BoxDecoration(),
                                        child: const Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Organizer',
                                        style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                          letterSpacing: -0.15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Location
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: const BoxDecoration(),
                                        child: const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          event.location.address,
                                          style: const TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.43,
                                            letterSpacing: -0.15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              height: 36,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFDC2626),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AttendeeEventDetailsPage(
                                        event: event,
                                      ),
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'View Details',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        height: 1.43,
                                        letterSpacing: -0.15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}