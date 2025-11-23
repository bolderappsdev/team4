import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadright/di/injection_container.dart';
import 'package:leadright/core/usecases/usecase.dart';
import 'package:leadright/features/auth/domain/usecases/is_profile_complete.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:leadright/features/auth/presentation/pages/main_page.dart';
import 'package:leadright/features/auth/presentation/pages/organizer_profile_setup_page.dart';
import 'package:leadright/features/auth/presentation/pages/select_user_type_page.dart';

/// Sign in page where users can log in with their email and password.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to dark content
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          final user = state.user;
          final isOrganizer = user.isOrganizer;

          if (isOrganizer) {
            // For organizers, check if profile is complete by checking displayName, bio, and contactEmail
            try {
              final firestore = getIt<FirebaseFirestore>();
              final userDoc = await firestore
                  .collection('users')
                  .doc(user.id)
                  .get();

              if (!userDoc.exists) {
                // User document doesn't exist, navigate to profile setup
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<AuthBloc>(),
                      child: const OrganizerProfileSetupPage(),
                    ),
                  ),
                );
                return;
              }

              final data = userDoc.data()!;
              final displayName = data['displayName'] as String?;
              final bio = data['bio'] as String?;
              final contactEmail = data['contactEmail'] as String?;

              // Check if all required fields are present and non-empty
              final isProfileComplete = (displayName != null && displayName.trim().isNotEmpty) &&
                                      (bio != null && bio.trim().isNotEmpty) &&
                                      (contactEmail != null && contactEmail.trim().isNotEmpty);

              if (isProfileComplete) {
                // Organizer profile is complete, navigate to main page
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<AuthBloc>(),
                      child: const MainPage(),
                    ),
                  ),
                );
              } else {
                // Organizer profile is incomplete, navigate to organizer profile setup page
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<AuthBloc>(),
                      child: const OrganizerProfileSetupPage(),
                    ),
                  ),
                );
              }
            } catch (e) {
              // If there's an error fetching user data, navigate to profile setup
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<AuthBloc>(),
                    child: const OrganizerProfileSetupPage(),
                  ),
                ),
              );
            }
          } else {
            // For attendees, check if profile is complete using the use case
            final isProfileCompleteUseCase = getIt<IsProfileComplete>();
            final profileResult = await isProfileCompleteUseCase(NoParams());
            
            profileResult.fold(
              (failure) {
                // If check fails, navigate to main page (default behavior)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<AuthBloc>(),
                      child: const MainPage(),
                    ),
                  ),
                );
              },
              (isComplete) {
                if (isComplete) {
                  // Attendee profile is complete, navigate to main page
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: context.read<AuthBloc>(),
                        child: const MainPage(),
                      ),
                    ),
                  );
                } else {
                  // Attendee profile is incomplete, navigate to complete profile page
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: context.read<AuthBloc>(),
                        child: const CompleteProfilePage(),
                      ),
                    ),
                  );
                }
              },
            );
          }
        } else if (state is AuthError) {
          // Show error message
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Header with back button and title
                _buildHeader(context),
                const SizedBox(height: 40),
                // Form fields
                _buildFormFields(),
                const SizedBox(height: 80),
                // Action buttons and footer
                _buildActions(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F1728)),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
        ),
        const Expanded(
          child: Text(
            'Log In',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0F1728),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 36), // Spacer for symmetry
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        _buildEmailField(),
        const SizedBox(height: 16),
        // Password field
        _buildPasswordField(),
        const SizedBox(height: 16),
        // Remember me and Forgot password
        _buildRememberAndForgot(),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            color: Color(0xFF667084),
            fontSize: 14,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w500,
            height: 1.43,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0xFFCFD4DC),
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
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: InputBorder.none,
              hintText: 'johndoe@gmail.com',
              hintStyle: TextStyle(
                color: Color(0xFF667084),
                fontSize: 16,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            color: Color(0xFF667084),
            fontSize: 14,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w500,
            height: 1.43,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0xFFCFD4DC),
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
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
              hintText: '••••••••',
              hintStyle: const TextStyle(
                color: Color(0xFF667084),
                fontSize: 16,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 16,
                  color: const Color(0xFF667084),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFCFD4DC),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Remember for 30 days',
                  style: TextStyle(
                    color: Color(0xFF667084),
                    fontSize: 14,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to forgot password page
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Forgot password',
            style: TextStyle(
              color: Color(0xFF667084),
              fontSize: 14,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w500,
              height: 1.43,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Column(
          children: [
            // Sign in button
            SizedBox(
              width: double.infinity,
              child: Material(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: isLoading
                      ? null
                      : () {
                          // Validate inputs
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;

                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter your email'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter your password'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Trigger sign in
                          context.read<AuthBloc>().add(
                                SignInRequested(
                                  email: email,
                                  password: password,
                                ),
                              );
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: ShapeDecoration(
                      color: isLoading
                          ? const Color(0xFF1E3A8A).withOpacity(0.6)
                          : const Color(0xFF1E3A8A),
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
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Sign in',
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
            // Sign up link
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SelectUserTypePage(),
                        ),
                      );
                    },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: "Don't have an account?",
                      style: TextStyle(
                        color: Color(0xFF667084),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                      ),
                    ),
                    TextSpan(
                      text: ' Sign Up',
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }
}

