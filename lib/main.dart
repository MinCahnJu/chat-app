import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as app_provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/friend_provider.dart';
import 'providers/opponent_provider.dart';
import 'providers/user_provider.dart';
import 'providers/chat_provider.dart';

import 'pages/chat_list_screen.dart';
import 'pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'],
    anonKey: dotenv.env['SUPABASE_ANON_KEY'],
  );

  runApp(
    app_provider.MultiProvider(
      providers: [
        app_provider.ChangeNotifierProvider(create: (_) => ChatProvider()),
        app_provider.ChangeNotifierProvider(create: (_) => UserProvider()),
        app_provider.ChangeNotifierProvider(create: (_) => FriendProvider()),
        app_provider.ChangeNotifierProvider(create: (_) => OpponentProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: app_provider.Provider.of<UserProvider>(context, listen: false)
          .loadUserFromStorage(),
      builder: (context, snapshot) {
        // Show a loading screen while checking the login state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final userProvider = app_provider.Provider.of<UserProvider>(context);
        return MaterialApp(
          title: 'Chat App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: userProvider.user != null ? ChatListScreen() : LoginScreen(),
        );
      },
    );
  }
}
