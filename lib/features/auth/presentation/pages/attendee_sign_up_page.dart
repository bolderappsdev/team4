import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/auth/presentation/pages/complete_profile_page.dart';

/// Page for Attendee account creation.
class AttendeeSignUpPage extends StatefulWidget {
  const AttendeeSignUpPage({super.key});

  @override
  State<AttendeeSignUpPage> createState() => _AttendeeSignUpPageState();
}

class _AttendeeSignUpPageState extends State<AttendeeSignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to complete profile page on successful sign up
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: context.read<AuthBloc>(),
                child: const CompleteProfilePage(),
              ),
            ),
          );
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const SizedBox(height: 32),
                // Status bar time (optional, usually handled by system)
                const SizedBox(height: 8),
                // Title section
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Create account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1D0A74),
                            fontSize: 24,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1.33,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Join LeadRight to discover events in your area',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w400,
                            height: 1.70,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Form section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email field
                    Column(
                      mainAxisSize: MainAxisSize.min,
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
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          clipBehavior: Clip.antiAlias,
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
                    ),
                    const SizedBox(height: 16),
                    // Password field
                    Column(
                      mainAxisSize: MainAxisSize.min,
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
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          clipBehavior: Clip.antiAlias,
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
                          child: Row(
                            children: [
                              Expanded(
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
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '••••••••',
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
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 16,
                                  color: const Color(0xFF667084),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password field
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Confirm Password ',
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
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          clipBehavior: Clip.antiAlias,
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
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '••••••••',
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
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                child: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 16,
                                  color: const Color(0xFF667084),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Terms and conditions checkbox
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _agreedToTerms = !_agreedToTerms;
                            });
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: _agreedToTerms
                                  ? const Color(0xFF1E3A8A)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: _agreedToTerms
                                      ? const Color(0xFF1E3A8A)
                                      : const Color(0xFFCFD4DC),
                                ),
                                borderRadius: BorderRadius.circular(55),
                              ),
                            ),
                            child: _agreedToTerms
                                ? const Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Wrap(
                            children: [
                              const Text(
                                'I agree with the ',
                                style: TextStyle(
                                  color: Color(0xFF98A1B2),
                                  fontSize: 12,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w500,
                                  height: 1.50,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // TODO: Navigate to Privacy Policy
                                },
                                child: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 12,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w500,
                                    height: 1.50,
                                  ),
                                ),
                              ),
                              const Text(
                                ' and ',
                                style: TextStyle(
                                  color: Color(0xFF98A1B2),
                                  fontSize: 12,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w500,
                                  height: 1.50,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // TODO: Navigate to Terms & Conditions
                                },
                                child: const Text(
                                  'Terms & Conditions',
                                  style: TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 12,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w500,
                                    height: 1.50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Create Account button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;

                        return Material(
                          color: (_agreedToTerms && !isLoading)
                              ? const Color(0xFF1E3A8A)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: (_agreedToTerms && !isLoading)
                                ? () {
                                    // Validate inputs
                                    final email = _emailController.text.trim();
                                    final password = _passwordController.text;
                                    final confirmPassword =
                                        _confirmPasswordController.text;

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
                                          content:
                                              Text('Please enter your password'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (password != confirmPassword) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Passwords do not match'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (password.length < 6) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Password must be at least 6 characters'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    // Extract display name from email (part before @)
                                    final displayName = email.split('@').first;

                                    // Trigger sign up
                                    context.read<AuthBloc>().add(
                                          SignUpRequested(
                                            email: email,
                                            password: password,
                                            displayName: displayName,
                                          ),
                                        );
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: (_agreedToTerms && !isLoading)
                                    ? const Color(0xFF1E3A8A)
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: (_agreedToTerms && !isLoading)
                                        ? const Color(0xFF1E3A8A)
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                shadows: (_agreedToTerms && !isLoading)
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
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Create Account',
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
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                // Sign In link
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Have an account? ',
                            style: TextStyle(
                              color: Color(0xFF667084),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.43,
                            ),
                          ),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Navigate to sign in page
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Color(0xFF1E3A8A),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  height: 1.43,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

