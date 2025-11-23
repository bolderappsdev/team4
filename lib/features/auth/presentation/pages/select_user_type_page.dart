import 'package:flutter/material.dart';
import 'attendee_sign_up_page.dart';

/// Page where users select their account type (Attendee or Organizer).
class SelectUserTypePage extends StatefulWidget {
  const SelectUserTypePage({super.key});

  @override
  State<SelectUserTypePage> createState() => _SelectUserTypePageState();
}

class _SelectUserTypePageState extends State<SelectUserTypePage> {
  String? _selectedUserType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF0F1728),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Choose Account Type',
          style: TextStyle(
            color: Color(0xFF0F1728),
            fontSize: 18,
            fontFamily: 'Futura PT',
            fontWeight: FontWeight.w500,
            height: 1.56,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Title
              const Text(
                'Choose account type',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontFamily: 'Futura PT',
                  fontWeight: FontWeight.w600,
                  height: 1.22,
                  letterSpacing: -0.72,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              const Text(
                'Are you an organizer or a attendee?',
                style: TextStyle(
                  color: Color(0xFF98A1B2),
                  fontSize: 18,
                  fontFamily: 'Futura PT',
                  fontWeight: FontWeight.w400,
                  height: 1.56,
                ),
              ),
              const SizedBox(height: 32),
              // User type options
              Expanded(
                child: Column(
                  children: [
                    // Attendee option
                    _UserTypeOption(
                      title: 'Attendee',
                      description: 'For people discovering and attending political events',
                      isSelected: _selectedUserType == 'attendee',
                      onTap: () {
                        setState(() {
                          _selectedUserType = 'attendee';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Organizer option
                    _UserTypeOption(
                      title: 'Organizer',
                      description: 'For organizations hosting political events',
                      isSelected: _selectedUserType == 'organizer',
                      onTap: () {
                        setState(() {
                          _selectedUserType = 'organizer';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Continue button
              _ContinueButton(
                isEnabled: _selectedUserType != null,
                onPressed: () {
                  if (_selectedUserType != null) {
                    if (_selectedUserType == 'attendee') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AttendeeSignUpPage(),
                        ),
                      );
                    } else {
                      // TODO: Navigate to organizer sign up page
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => const OrganizerSignUpPage(),
                      //   ),
                      // );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// User type option card widget
class _UserTypeOption extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeOption({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: ShapeDecoration(
            color: const Color(0xFFF6F6F6),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: isSelected
                    ? const Color(0xFF3375C6)
                    : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0F1728),
                        fontSize: 16,
                        fontFamily: 'Futura PT',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF667084),
                        fontSize: 14,
                        fontFamily: 'Futura PT',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Radio button indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3375C6)
                        : const Color(0xFF667084),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3375C6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Continue button widget
class _ContinueButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const _ContinueButton({
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isEnabled ? const Color(0xFF1E3A8A) : Colors.grey,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: isEnabled ? const Color(0xFF1E3A8A) : Colors.grey,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: isEnabled ? const Color(0xFF1E3A8A) : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            shadows: isEnabled
                ? const [
                    BoxShadow(
                      color: Color(0x0C101828),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: const Center(
            child: Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

