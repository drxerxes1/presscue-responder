import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:presscue_patroller/core/database/boxes.dart';
import 'package:presscue_patroller/core/database/user.dart';
import 'core/constants/app_colors.dart';
import 'core/database/base_url.dart';
import 'core/navigation/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> setup() async {
  await dotenv.load(fileName: "assets/config/.env");
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(BaseUrlModelAdapter());

  boxUsers = await Hive.openBox<User>('userBox');
  baseUrlBox = await Hive.openBox<BaseUrlModel>('userBaseUrl');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.accent,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primaryColor,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
