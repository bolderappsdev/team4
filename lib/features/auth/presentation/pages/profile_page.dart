import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/auth/presentation/pages/my_attendance_page.dart';

/// Profile page showing user information and settings.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
            return Stack(
              children: [
                // Main content
                Positioned(
                  left: 0,
                  top: 0,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(
                      top: 56,
                      left: 16,
                      right: 16,
                      bottom: 12,
                    ),
                    decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            Container(
                                width: 48,
                                height: 48,
                                decoration: ShapeDecoration(
                                  image: state.user.photoUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(state.user.photoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: state.user.photoUrl == null
                                      ? const Color(0xFF1E3A8A)
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                ),
                                child: state.user.photoUrl == null
                                    ? Center(
                                child: Text(
                                  state.user.displayName?.isNotEmpty == true
                                      ? state.user.displayName![0].toUpperCase()
                                      : state.user.email[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                            fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Name and Email
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: Text(
                              state.user.displayName ?? 'User',
                              style: const TextStyle(
                                color: Color(0xFF0F1728),
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                                height: 1.20,
                                              ),
                              ),
                            ),
                            const SizedBox(height: 4),
                                          SizedBox(
                                            width: double.infinity,
                                            child: Text(
                              state.user.email,
                              style: const TextStyle(
                                                color: Color(0xFF475466),
                                                fontSize: 16,
                                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                                height: 1.25,
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
                  ),
                ),
                // Settings Menu
                Positioned(
                  left: 16,
                  top: 132,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 32,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x3DE4E5E7),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        )
                      ],
                        ),
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        // Personal Information
                        _SettingsMenuItem(
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Personal Information - Coming soon'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFF2F3F6)),
                        // My Events
                        _SettingsMenuItem(
                          icon: Icons.event,
                          title: 'My Events',
                              onTap: () {
                            // Navigate to My Attendance page
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MyAttendancePage(),
                                  ),
                                );
                              },
                            ),
                        const Divider(height: 1, color: Color(0xFFF2F3F6)),
                        // Notifications
                        _SettingsMenuItem(
                              icon: Icons.notifications_outlined,
                              title: 'Notifications',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Notifications - Coming soon'),
                                  ),
                                );
                              },
                            ),
                        const Divider(height: 1, color: Color(0xFFF2F3F6)),
                        // Terms of Use
                        _SettingsMenuItem(
                          icon: Icons.description_outlined,
                          title: 'Terms of Use',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Terms of Use - Coming soon'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFF2F3F6)),
                        // Privacy Policy
                        _SettingsMenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                content: Text('Privacy Policy - Coming soon'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Logout
                        _SettingsMenuItem(
                          icon: Icons.logout,
                          title: 'Logout',
                          iconColor: const Color(0xFFF97066),
                          titleColor: const Color(0xFFF97066),
                          backgroundColor: const Color(0xFFFEF2F1),
                          onTap: () {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text('Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      context.read<AuthBloc>().add(const SignOutRequested());
                                    },
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(color: Color(0xFFDC2626)),
                                    ),
                                  ),
                                ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                ),
                // Bottom Navigation Bar
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 96,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 0.50,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color(0xFFF2F3F6),
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
                                          child: const Icon(
                                            Icons.home,
                                            size: 24,
                                            color: Color(0xFF667084),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                            const Text(
                                          'Home',
                                          textAlign: TextAlign.center,
                              style: TextStyle(
                                            color: Color(0xFF667084),
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
                                // My Events Tab
                                Expanded(
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
                                          child: const Icon(
                                            Icons.event_available,
                                            size: 24,
                                            color: Color(0xFF667084),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'My Events',
                                          textAlign: TextAlign.center,
                                  style: TextStyle(
                                            color: Color(0xFF667084),
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
                                // Profile Tab (Active)
                                Expanded(
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
                                          child: const Icon(
                                            Icons.person,
                                            size: 24,
                                            color: Color(0xFFDC2626),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Profile',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFFDC2626),
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
                              ],
                            ),
                          ),
                        ),
                        // Safe area spacer
                        Container(
                          width: double.infinity,
                          height: 34,
                          child: const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Status Bar (Time)
                Positioned(
                  left: 24,
                  top: 16,
                  child: Text(
                    _getCurrentTime(),
                    style: const TextStyle(
                      color: Color(0xFF0F1728),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
              ],
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
      ),
    );
  }

  String _getCurrentTime() {
      final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;
  final Color? backgroundColor;

  const _SettingsMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = iconColor ?? const Color(0xFF667084);
    final defaultTitleColor = titleColor ?? const Color(0xFF0F1728);
    final defaultBackgroundColor = backgroundColor ?? const Color(0xFFE8EBF3);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFF2F3F6),
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  padding: const EdgeInsets.all(4),
                  decoration: ShapeDecoration(
                    color: defaultBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Icon(
              icon,
                    size: 20,
                    color: defaultIconColor,
                  ),
            ),
            const SizedBox(width: 12),
                Text(
                title,
                  style: TextStyle(
                    color: defaultTitleColor,
                  fontSize: 16,
                  fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFF667084),
            ),
          ],
        ),
      ),
    );
  }
}
