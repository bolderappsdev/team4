import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';

/// Page for completing user profile after sign up.
class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

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
          child: Center(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Complete Profile',
                      style: TextStyle(
                        color: Color(0xFF1D0A74),
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 200,
                      child: Material(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: isLoading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                        const SignOutRequested(),
                                      );
                                },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: ShapeDecoration(
                              color: isLoading
                                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.6)
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Log Out',
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
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

