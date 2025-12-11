import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:leadright/core/utils/constants.dart';
import 'package:leadright/di/injection_container.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/auth/presentation/pages/onboarding_page.dart';
import 'package:leadright/firebase_options.dart';
import 'package:leadright/presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Stripe
  Stripe.publishableKey = AppConstants.stripePublishableKey;
  Stripe.merchantIdentifier = 'merchant.com.leadright';
  
  // Initialize dependency injection
  await configureDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Material(
        title: 'LeadRight'
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
