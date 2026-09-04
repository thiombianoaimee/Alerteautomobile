import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'presentation/screen/accueil/accueil_screen.dart';
import 'presentation/screen/automobiliste/notifications_screen.dart';
import 'presentation/screen/automobiliste/profil_auto_screen.dart';
import 'presentation/screen/auth/reset_password_screen.dart';
import 'metier/models/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();

  final GlobalKey<NavigatorState> _navigatorKey =
  GlobalKey<NavigatorState>();

  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initialiserDeepLinks();
  }

  // ============================================================
  // INITIALISATION DES DEEP LINKS
  // ============================================================

  Future<void> _initialiserDeepLinks() async {
    // ------------------------------------------------------------
    // Application complètement fermée
    // ------------------------------------------------------------
    try {
      final Uri? uri = await _appLinks.getInitialLink();

      if (uri != null) {
        debugPrint("========== LIEN INITIAL ==========");
        debugPrint("URI : $uri");

        _traiterDeepLink(uri);
      }
    } catch (e) {
      debugPrint("Erreur récupération lien initial : $e");
    }

    // ------------------------------------------------------------
    // Application déjà ouverte
    // ------------------------------------------------------------
    _linkSubscription = _appLinks.uriLinkStream.listen(
          (Uri uri) {
        debugPrint("========== DEEP LINK ==========");
        debugPrint("URI reçue : $uri");
        debugPrint("Scheme : ${uri.scheme}");
        debugPrint("Host : ${uri.host}");
        debugPrint("Path : ${uri.path}");
        debugPrint("Path segments : ${uri.pathSegments}");

        _traiterDeepLink(uri);
      },
      onError: (error) {
        debugPrint("Erreur réception deep link : $error");
      },
    );
  }

  // ============================================================
  // TRAITEMENT DU DEEP LINK
  // ============================================================

  void _traiterDeepLink(Uri uri) {
    // Vérifier le scheme
    if (uri.scheme != 'visiteapp') {
      debugPrint("❌ Scheme inconnu : ${uri.scheme}");
      return;
    }

    // Vérifier l'hôte
    if (uri.host != 'reset-password') {
      debugPrint("❌ Host inconnu : ${uri.host}");
      return;
    }

    // Vérifier la présence du token
    if (uri.pathSegments.isEmpty) {
      debugPrint("❌ Aucun token trouvé dans le lien.");
      return;
    }

    final String token = uri.pathSegments.first;

    if (token.isEmpty) {
      debugPrint("❌ Token vide.");
      return;
    }

    debugPrint("========== TOKEN ==========");
    debugPrint("Token extrait : $token");

    // Attendre que MaterialApp/Navigator soit disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey.currentState;

      if (navigator == null) {
        debugPrint("❌ Navigator indisponible.");
        return;
      }

      debugPrint("✅ Ouverture de ResetPasswordScreen");

      navigator.push(
        MaterialPageRoute(
          builder: (context) {
            return ResetPasswordScreen(
              token: token,
            );
          },
        ),
      );
    });
  }

  // ============================================================
  // LIBÉRATION DES RESSOURCES
  // ============================================================

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  // ============================================================
  // INTERFACE PRINCIPALE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,

      debugShowCheckedModeBanner: false,

      title: 'Visite App',

      // ==========================================================
      // LOCALISATION
      // ==========================================================

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],

      // ==========================================================
      // THÈME
      // ==========================================================

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFFFFA000),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1E88E5),
            side: const BorderSide(
              color: Color(0xFF1E88E5),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF1E88E5),
              width: 2,
            ),
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),

      // ==========================================================
      // ÉCRAN D'ACCUEIL
      // ==========================================================

      home: const AccueilScreen(),

      // ==========================================================
      // ROUTES NORMALES
      // ==========================================================

      routes: {
        '/notifications': (context) {
          return NotificationsScreen();
        },

        '/profil': (context) {
          final user =
          ModalRoute.of(context)!.settings.arguments as UserModel;

          return ProfilAutoScreen(
            user: user,
          );
        },
      },

      // ==========================================================
      // GESTION DES ROUTES TRANSMISES PAR ANDROID
      // ==========================================================

      onGenerateRoute: (settings) {
        final String? routeName = settings.name;

        debugPrint(
          "========== ROUTE FLUTTER ==========",
        );

        debugPrint(
          "Route reçue : $routeName",
        );

        // Android peut transmettre :
        //
        // /TEST123
        //
        // au lieu de laisser uniquement app_links gérer
        // le deep link.
        //
        // On retourne simplement une route valide pour éviter
        // l'exception "Could not find a generator".

        if (routeName != null &&
            routeName.startsWith('/') &&
            routeName.length > 1) {
          final String token = routeName.substring(1);

          debugPrint(
            "Token de route : $token",
          );

          return MaterialPageRoute(
            builder: (context) {
              return ResetPasswordScreen(
                token: token,
              );
            },
          );
        }

        // Route inconnue
        return null;
      },
    );
  }
}