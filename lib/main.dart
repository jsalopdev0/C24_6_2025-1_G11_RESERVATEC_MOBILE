import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:reservatec/screens/home_screen.dart';
import 'package:reservatec/screens/login_screen.dart';
import 'package:reservatec/services/storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Acepta certificados no confiables (solo para desarrollo)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Permitir HTTPS con certificado no válido (solo en desarrollo)
  HttpOverrides.global = MyHttpOverrides();

  await initializeDateFormatting('es_ES', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final session = await Storage.getUserSession();
    final userId = await Storage.getUserId();

    if (session != null && userId != null) {
      final token = session["token"]!;
      final isExpired = JwtDecoder.isExpired(token);

      if (!isExpired) {
        return HomeScreen(
          name: session["name"]!,
          email: session["email"]!,
          photoUrl: session["photo"]!,
          accessToken: token,
          userId: userId,
        );
      } else {
        await Storage.clearSession();
      }
    }

    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ReservaTec',
          themeMode: ThemeMode.light,
          theme: ThemeData.light().copyWith(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00AEEF),
            ),
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Color(0xFF00AEEF),
            ),
            scaffoldBackgroundColor: Colors.grey[100],
            textTheme: ThemeData.light().textTheme.apply(
                  fontFamily: 'Roboto',
                ),
          ),
          supportedLocales: const [
            Locale('es', 'ES'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: FutureBuilder<Widget>(
            future: _getInitialScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return snapshot.data!;
              } else {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        );
      },
    );
  }
}