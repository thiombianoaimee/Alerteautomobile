import 'package:flutter/material.dart';
import 'presentation/screen/accueil/accueil_screen.dart';
import 'presentation/screen/automobiliste/notifications_screen.dart';
import 'metier/models/user_model.dart';
import 'presentation/screen/automobiliste/profil_auto_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
void main() {

  runApp(const MyApp());

}



class MyApp extends StatelessWidget {

  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Visite App',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],

      theme: ThemeData(

        primarySwatch: Colors.blue,

      ),

      home: const AccueilScreen(),
      routes: {
        '/notifications': (context) => NotificationsScreen(

        ),
        '/profil': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as UserModel;

          return ProfilAutoScreen(
            user: user,
          );
        },

      },

    );


  }

}