import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';

/// Page for email verification after sign up.
class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isResending = false;
  bool _hasResent = false;

  @override
  void initState() {
    super.initState();
    // Set status bar to dark content
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _handleOpenEmailApp() async {
    try {
      final emailScheme = Uri.parse('mailto:');
      if (await canLaunchUrl(emailScheme)) {
        await launchUrl(emailScheme);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open email app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening email app: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleResendLink() async {
    if (_isResending || _hasResent) return;

    setState(() {
      _isResending = true;
    });

    // TODO: Implement actual resend email verification logic
    // For now, simulate a delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isResending = false;
        _hasResent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification link sent successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset the "has resent" state after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _hasResent = false;
          });
        }
      });
    }
  }

  String _getUserEmail(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      return state.user.email;
    }
    return 'your@email.com';
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
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final userEmail = _getUserEmail(context);

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        // Header section
                        _buildHeader(context),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                        ),
                        // Main content
                        Flexible(
                          child: _buildContent(context, userEmail),
                        ),
                        const Spacer(),
                        // Bottom indicator (home indicator for iOS)
                        const SizedBox(height: 16),
                        _buildBottomIndicator(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF0F1728),
              size: 24,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Expanded(
          child: Text(
            'Email Verification',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F1728),
              fontSize: 18,
              fontFamily: 'Futura PT',
              fontWeight: FontWeight.w500,
              height: 1.56,
            ),
          ),
        ),
        const SizedBox(width: 36),
      ],
    );
  }

  Widget _buildContent(BuildContext context, String userEmail) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon and title section
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Email icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 40,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'Verify your email',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'We've sent a verification link to ',
                      style: TextStyle(
                        color: Color(0xFF667084),
                        fontSize: 16,
                        fontFamily: 'Futura PT',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    TextSpan(
                      text: '$userEmail. ',
                      style: const TextStyle(
                        color: Color(0xFF667084),
                        fontSize: 16,
                        fontFamily: 'Futura PT',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                    ),
                    const TextSpan(
                      text: 'Please check your inbox and click the link to confirm your account.',
                      style: TextStyle(
                        color: Color(0xFF667084),
                        fontSize: 16,
                        fontFamily: 'Futura PT',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        // Action buttons
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Open Email App button
            SizedBox(
              width: double.infinity,
              child: Material(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: _handleOpenEmailApp,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFF1E3A8A),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x0C101828),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Open Email App',
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
              ),
            ),
            const SizedBox(height: 16),
            // Resend link button
            GestureDetector(
              onTap: _isResending || _hasResent ? null : _handleResendLink,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _isResending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF8F2326),
                          ),
                        ),
                      )
                    : Text(
                        _hasResent ? 'Link sent!' : 'Resend link',
                        style: TextStyle(
                          color: _hasResent
                              ? Colors.green
                              : const Color(0xFF8F2326),
                          fontSize: 16,
                          fontFamily: 'Futura PT',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomIndicator() {
    return Container(
      width: 134,
      height: 5,
      decoration: ShapeDecoration(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}

