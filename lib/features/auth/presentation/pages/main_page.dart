import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/auth/presentation/pages/home_page.dart';
import 'package:leadright/features/auth/presentation/pages/my_attendance_page.dart';
import 'package:leadright/features/auth/presentation/pages/organizer_home_page.dart';
import 'package:leadright/features/auth/presentation/pages/profile_page.dart';

/// Main page with bottom navigation bar for Home, My Attendance, and Profile.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  List<Widget> _buildPages(bool isOrganizer) {
    if (isOrganizer) {
      return const [
        OrganizerHomePage(),
        MyAttendancePage(),
        ProfilePage(),
      ];
    }
    return const [
      HomePage(),
      MyAttendancePage(),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Navigate back to sign in page when logged out
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isOrganizer = authState is AuthAuthenticated &&
              authState.user.isOrganizer;
          final pages = _buildPages(isOrganizer);

          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FB),
            body: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      width: 375,
      height: 96,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 0.50,
            strokeAlign: BorderSide.strokeAlignCenter,
            color: const Color(0xFFF2F3F6),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Home Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = 0;
                        });
                      },
                      child: Container(
                        height: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              child: Icon(
                                Icons.home,
                                size: 24,
                                color: _currentIndex == 0
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF667084),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Home',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _currentIndex == 0
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF667084),
                                fontSize: 12,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w400,
                                height: 1.33,
                                letterSpacing: -0.08,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // My Attendance Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                      child: Container(
                        height: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              child: Icon(
                                Icons.event_available,
                                size: 24,
                                color: _currentIndex == 1
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF667084),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'My Attendance',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _currentIndex == 1
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF667084),
                                fontSize: 12,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w400,
                                height: 1.33,
                                letterSpacing: -0.08,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Profile Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = 2;
                        });
                      },
                      child: Container(
                        height: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              child: Icon(
                                Icons.person,
                                size: 24,
                                color: _currentIndex == 2
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF667084),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Profile',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _currentIndex == 2
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF667084),
                                fontSize: 12,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w400,
                                height: 1.33,
                                letterSpacing: -0.08,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Safe area spacer
          Container(
            width: 375,
            height: 34,
            child: const SizedBox(),
          ),
        ],
      ),
    );
  }
}

