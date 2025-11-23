import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadright/di/injection_container.dart';
import 'package:leadright/features/auth/domain/entities/user.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/events/domain/entities/event.dart';
import 'package:leadright/features/events/presentation/bloc/events_bloc.dart';
import 'package:leadright/features/events/presentation/pages/event_details_page.dart';
import 'package:leadright/features/events/presentation/widgets/organizer_event_card.dart';

/// Home page for organizers displaying their events with management capabilities.
class OrganizerHomePage extends StatefulWidget {
  const OrganizerHomePage({super.key});

  @override
  State<OrganizerHomePage> createState() => _OrganizerHomePageState();
}

class _OrganizerHomePageState extends State<OrganizerHomePage> {
  String _searchQuery = '';
  String _selectedFilter = 'Upcoming';
  String _selectedStatusFilter = 'All Statuses';
  String? _lastFetchedOrgId;
  bool _isCreatingOrganization = false;

  void _fetchEventsIfNeeded(String orgId, BuildContext context) {
    if (orgId != _lastFetchedOrgId) {
      _lastFetchedOrgId = orgId;
      context.read<EventsBloc>().add(FetchOrganizerEvents(orgId));
    }
  }

  /// Create organization if profile is complete but organizationId is missing
  Future<void> _createOrganizationIfNeeded(BuildContext context, User user) async {
    if (_isCreatingOrganization) return;
    
    try {
      final firestore = getIt<FirebaseFirestore>();
      final firebaseAuth = firebase_auth.FirebaseAuth.instance;
      final currentUser = firebaseAuth.currentUser;
      
      if (currentUser == null) return;
      
      // Get user document from Firestore
      final userDoc = await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return;
      
      final userData = userDoc.data()!;
      final displayName = userData['displayName'] as String?;
      final bio = userData['bio'] as String?;
      final contactEmail = userData['contactEmail'] as String?;
      
      // Check if profile is complete (has displayName, bio, contactEmail)
      final isProfileComplete = displayName != null && 
          displayName.isNotEmpty &&
          bio != null && 
          bio.isNotEmpty &&
          contactEmail != null && 
          contactEmail.isNotEmpty;
      
      // If profile is complete but no organizationId, trigger profile update
      // which will now create the organization
      if (isProfileComplete && (user.organizationId == null || user.organizationId!.isEmpty)) {
        setState(() {
          _isCreatingOrganization = true;
        });
        
        // Trigger profile update with existing data to create organization
        context.read<AuthBloc>().add(
          UpdateProfileRequested(
            displayName: displayName,
            bio: bio,
            contactEmail: contactEmail,
            website: userData['website'] as String?,
            photoUrl: userData['photoUrl'] as String?,
          ),
        );
      }
    } catch (e) {
      // Silently fail - user can manually update profile
      setState(() {
        _isCreatingOrganization = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<EventsBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticated) {
            final orgId = authState.user.organizationId;
            if (orgId != null && orgId.isNotEmpty) {
              _fetchEventsIfNeeded(orgId, context);
              // Reset creating flag if organization is now set
              if (_isCreatingOrganization) {
                setState(() {
                  _isCreatingOrganization = false;
                });
              }
            }
          } else if (authState is AuthError) {
            // Reset creating flag on error
            if (_isCreatingOrganization) {
              setState(() {
                _isCreatingOrganization = false;
              });
            }
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthAuthenticated) {
              final user = authState.user;
              final orgId = user.organizationId;

              // Check if we need to create organization for complete profile
              if (orgId == null || orgId.isEmpty) {
                // Try to create organization if profile is complete
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _createOrganizationIfNeeded(context, user);
                });
                
                // Show loading or message while creating organization
                if (_isCreatingOrganization) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                return const Scaffold(
                  body: Center(
                    child: Text('No organization found. Please complete your profile.'),
                  ),
                );
              }

              // Fetch events on initial load
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fetchEventsIfNeeded(orgId, context);
              });

              return SafeArea(
                child: Scaffold(
                  backgroundColor: const Color(0xFFF8F9FB),
                  body: Column(
                    children: [
                      // Header Section
                      _HeaderSection(
                        onCreateEvent: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const EventDetailsPage(),
                            ),
                          );
                        },
                      ),
                      // Search and Filters
                      _SearchAndFiltersSection(
                        searchQuery: _searchQuery,
                        selectedFilter: _selectedFilter,
                        selectedStatusFilter: _selectedStatusFilter,
                        onSearchChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        onFilterChanged: (value) {
                          setState(() {
                            _selectedFilter = value;
                          });
                        },
                        onStatusFilterChanged: (value) {
                          setState(() {
                            _selectedStatusFilter = value;
                          });
                        },
                      ),
                      // Events List
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
                                            .add(FetchOrganizerEvents(orgId));
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              );
                            } else if (eventsState is EventsLoaded) {
                              final filteredEvents = _filterEvents(
                                eventsState.events,
                                _searchQuery,
                                _selectedFilter,
                                _selectedStatusFilter,
                              );

                              if (filteredEvents.isEmpty) {
                                return Center(
                                  child: Text(
                                    _searchQuery.isNotEmpty ||
                                            _selectedFilter != 'Upcoming' ||
                                            _selectedStatusFilter != 'All Statuses'
                                        ? 'No events match your filters'
                                        : 'No events yet. Create your first event!',
                                    style: const TextStyle(
                                      color: Color(0xFF0F1728),
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }

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
                                        itemCount: filteredEvents.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final event = filteredEvents[index];
                                          return OrganizerEventCard(
                                            event: event,
                                            onView: () {
                                              // TODO: Navigate to event details page
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text('Viewing ${event.title}'),
                                                ),
                                              );
                                            },
                                            onEdit: () {
                                              // TODO: Navigate to edit event page
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text('Editing ${event.title}'),
                                                ),
                                              );
                                            },
                                            onDelete: () {
                                              // TODO: Show delete confirmation dialog
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text('Delete ${event.title}'),
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
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  /// Filter events based on search query, time filter, and status filter.
  List<Event> _filterEvents(
    List<Event> events,
    String searchQuery,
    String timeFilter,
    String statusFilter,
  ) {
    var filtered = events;

    // Search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((event) {
        return event.title
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            event.description
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            event.location.address
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Time filter
    if (timeFilter == 'Upcoming') {
      final now = DateTime.now();
      filtered = filtered.where((event) => event.startAt.isAfter(now)).toList();
    } else if (timeFilter == 'Past') {
      final now = DateTime.now();
      filtered = filtered.where((event) => event.startAt.isBefore(now)).toList();
    }
    // "All" doesn't filter by time

    // Status filter
    if (statusFilter != 'All Statuses') {
      final statusMap = {
        'Approved': ['approved', 'published'],
        'Pending': ['pending'],
        'Cancelled': ['cancelled'],
      };
      final allowedStatuses = statusMap[statusFilter] ?? [];
      filtered = filtered
          .where((event) => allowedStatuses.contains(event.status.toLowerCase()))
          .toList();
    }

    return filtered;
  }
}

/// Header section with logo, app name, and create event button.
class _HeaderSection extends StatelessWidget {
  final VoidCallback onCreateEvent;

  const _HeaderSection({
    required this.onCreateEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Top Row: Logo and Create Event Button
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
              // Create Event Button
              GestureDetector(
                onTap: onCreateEvent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF1B388E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Create Event',
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
        ],
      ),
    );
  }
}

/// Search and filters section.
class _SearchAndFiltersSection extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;
  final String selectedStatusFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onStatusFilterChanged;

  const _SearchAndFiltersSection({
    required this.searchQuery,
    required this.selectedFilter,
    required this.selectedStatusFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onStatusFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: ShapeDecoration(
              color: const Color(0xFFF6F6F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search,
                  size: 16,
                  color: Color(0xFF667084),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: Color(0xFF667084),
                        fontSize: 14,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FilterChip(
                  label: selectedFilter,
                  onTap: () {
                    // TODO: Show filter options
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _FilterBottomSheet(
                        selectedFilter: selectedFilter,
                        onFilterSelected: onFilterChanged,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _FilterChip(
                  label: selectedStatusFilter,
                  onTap: () {
                    // TODO: Show status filter options
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _StatusFilterBottomSheet(
                        selectedFilter: selectedStatusFilter,
                        onFilterSelected: onStatusFilterChanged,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Filter chip widget.
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: const Color(0xFFF6F6F6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF667084),
                  fontSize: 12,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
                overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

/// Filter bottom sheet for time filter.
class _FilterBottomSheet extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const _FilterBottomSheet({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['Upcoming', 'Past', 'All'];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter by Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...filters.map((filter) {
            return ListTile(
              title: Text(filter),
              trailing: selectedFilter == filter
                  ? const Icon(Icons.check, color: Color(0xFF1E3A8A))
                  : null,
              onTap: () {
                onFilterSelected(filter);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}

/// Status filter bottom sheet.
class _StatusFilterBottomSheet extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const _StatusFilterBottomSheet({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All Statuses', 'Approved', 'Pending', 'Cancelled'];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...filters.map((filter) {
            return ListTile(
              title: Text(filter),
              trailing: selectedFilter == filter
                  ? const Icon(Icons.check, color: Color(0xFF1E3A8A))
                  : null,
              onTap: () {
                onFilterSelected(filter);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}

