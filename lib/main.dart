import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sole_mate/provider/auth_provider.dart';
import 'package:sole_mate/provider/favouritized.dart';
import 'package:sole_mate/provider/preferences_provider.dart';
import 'package:sole_mate/provider/products_provider.dart';
import 'package:sole_mate/provider/profileprovider.dart';
import 'package:sole_mate/provider/theme_provider.dart';
import 'package:sole_mate/screens/bottomapbar.dart';
import 'package:sole_mate/screens/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
final prefs = await SharedPreferences.getInstance();
 
 // Check both sets of data
 final hasFirstSetData = prefs.getString('auth_token') != null && 
                        prefs.getString('selected_gender') != null && 
                        (prefs.getStringList('selected_brands') ?? []).isNotEmpty;
                        
 final hasSecondSetData = prefs.getBool('is_google_user') == true && 
                         prefs.getString('auth_token') != null && prefs.getString('selected_gender') != null && 
                        (prefs.getStringList('selected_brands') ?? []).isNotEmpty;

 // Navigate based on either set being complete
 final Widget initialScreen = (hasFirstSetData || hasSecondSetData) 
     ? const CustomBottomNavBar()
     : const GetStartedScreen();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => FavouriteProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PreferenceProvider()),
      ],
      child: SoulmateApp(initialScreen: initialScreen),
    ),
  );
}

class SoulmateApp extends StatelessWidget {
  final Widget initialScreen;

  const SoulmateApp({required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sole Mate',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          home: initialScreen,
        );
      },
    );
  }
}
