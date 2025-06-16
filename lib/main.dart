import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'Firebase/ratingFirebase.dart';
import 'firebase_options.dart';
import 'repository/RatingRepository.dart';
import 'repository/add-service_repository.dart';
import 'repository/display_service_repository.dart';
import 'repository/update-service_repository.dart';
import 'repository/view_rating_repository.dart';
import 'routes/appRoutes.dart';
import 'theme/app_colors.dart';
import 'views/user_management/forgot_password.dart';
import 'views/user_management/login.dart';
import 'views/user_management/role.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            Provider<FirebaseService>(create: (_) => FirebaseService()),
            Provider<addServiceRepository>(create: (_) => addServiceRepository()),
            Provider<RatingRepository>(create: (_) => RatingRepository()),
            Provider<viewRatingRepository>(create: (_) => viewRatingRepository()),
            Provider<updateServiceRepository>(create: (_) => updateServiceRepository()),
            Provider<ServiceRepository>(create: (_) => ServiceRepository()),
          ],
          child: MaterialApp(
            title: 'ServiceHub',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.teal,
              fontFamily: 'Roboto',
              textTheme: GoogleFonts.poppinsTextTheme(),
              scaffoldBackgroundColor: Colors.grey[200],
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                elevation: 4,
                centerTitle: true,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
            home: const LoginScreen(),
            routes: {
              '/role-selection': (context) => const RoleSelectionScreen(),
              '/forgot-password': (context) =>  ForgotPasswordScreen(),
            },
          ),
        );
      },
    );
  }
}
