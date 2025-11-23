import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/auth/presentation/pages/email_verification_page.dart';

/// Page for completing user profile after sign up.
class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'First name can only contain letters';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    if (value.trim().length < 2) {
      return 'Last name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Last name can only contain letters';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (digitsOnly.length > 15) {
      return 'Phone number is too long';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'City is required';
    }
    if (value.trim().length < 2) {
      return 'City must be at least 2 characters';
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'State is required';
    }
    if (value.trim().length < 2) {
      return 'State must be at least 2 characters';
    }
    return null;
  }

  String? _validateZipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Zip code is required';
    }
    final zipCode = value.trim();
    // US zip code validation (5 digits or 5+4 format)
    if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(zipCode)) {
      return 'Please enter a valid zip code';
    }
    return null;
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement profile completion logic
      // Navigate to email verification page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<AuthBloc>(),
            child: const EmailVerificationPage(),
          ),
        ),
      );
    }
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
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                // App bar with back button and title
                                Row(
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
                                        'Complete Your Profile',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF0F1728),
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 36),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Form fields
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // First Name and Last Name Row
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'First Name',
                                                style: const TextStyle(
                                                  color: Color(0xFF667084),
                                                  fontSize: 14,
                                                  fontFamily: 'Quicksand',
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.43,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              TextFormField(
                                                controller: _firstNameController,
                                                validator: _validateFirstName,
                                                enabled: !isLoading,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontFamily: 'Quicksand',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.50,
                                                ),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFFCFD4DC),
                                                    ),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFFCFD4DC),
                                                    ),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFF1E3A8A),
                                                    ),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  focusedErrorBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  errorStyle: const TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'Quicksand',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Last Name',
                                                style: const TextStyle(
                                                  color: Color(0xFF667084),
                                                  fontSize: 14,
                                                  fontFamily: 'Quicksand',
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.43,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              TextFormField(
                                                controller: _lastNameController,
                                                validator: _validateLastName,
                                                enabled: !isLoading,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontFamily: 'Quicksand',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.50,
                                                ),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFFCFD4DC),
                                                    ),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFFCFD4DC),
                                                    ),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFF1E3A8A),
                                                    ),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  focusedErrorBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  errorStyle: const TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'Quicksand',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Phone Number
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Phone Number',
                                          style: const TextStyle(
                                            color: Color(0xFF667084),
                                            fontSize: 14,
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.w500,
                                            height: 1.43,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _phoneNumberController,
                                          validator: _validatePhoneNumber,
                                          enabled: !isLoading,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'[\d\s\-\+\(\)]'),
                                            ),
                                          ],
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFCFD4DC),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFCFD4DC),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFF1E3A8A),
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.red,
                                              ),
                                            ),
                                            errorStyle: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Quicksand',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // City
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'City',
                                          style: const TextStyle(
                                            color: Color(0xFF667084),
                                            fontSize: 14,
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.w500,
                                            height: 1.43,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _cityController,
                                          validator: _validateCity,
                                          enabled: !isLoading,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFCFD4DC),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFCFD4DC),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFF1E3A8A),
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.red,
                                              ),
                                            ),
                                            errorStyle: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Quicksand',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // State and Zip Code Row
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'State',
                                                style: const TextStyle(
                                                  color: Color(0xFF667084),
                                                  fontSize: 14,
                                                  fontFamily: 'Quicksand',
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.43,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              TextFormField(
                                                controller: _stateController,
                                                validator: _validateState,
                                                enabled: !isLoading,
                                                textCapitalization: TextCapitalization.characters,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontFamily: 'Quicksand',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.50,
                                                ),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFFCFD4DC),
                                                    ),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFFCFD4DC),
                                                    ),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFF1E3A8A),
                                                    ),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  focusedErrorBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  errorStyle: const TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'Quicksand',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Zip Code',
                                                style: const TextStyle(
                                                  color: Color(0xFF667084),
                                                  fontSize: 14,
                                                  fontFamily: 'Quicksand',
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.43,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              TextFormField(
                                                controller: _zipCodeController,
                                                validator: _validateZipCode,
                                                enabled: !isLoading,
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(
                                                    RegExp(r'[\d\-]'),
                                                  ),
                                                ],
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontFamily: 'Quicksand',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.50,
                                                ),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFFCFD4DC),
                                                    ),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFFCFD4DC),
                                                    ),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFF1E3A8A),
                                                    ),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  focusedErrorBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  errorStyle: const TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'Quicksand',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Continue button section
                            Padding(
                              padding: const EdgeInsets.only(top: 80, bottom: 16),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Material(
                                      color: isLoading
                                          ? const Color(0xFF1E3A8A).withValues(alpha: 0.6)
                                          : const Color(0xFF1E3A8A),
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        onTap: isLoading ? null : _handleContinue,
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
                                    ),
                                  ),
                                  // Bottom indicator (home indicator for iOS)
                                  const SizedBox(height: 16),
                                  Container(
                                    width: 134,
                                    height: 5,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: ShapeDecoration(
                                      color: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
