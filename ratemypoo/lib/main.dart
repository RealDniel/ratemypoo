import 'dart:html' as html;
import 'package:ratemypoo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ratemypoo/pages/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void injectGoogleMapsScript() {
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  if (apiKey != null) {
    final script = html.ScriptElement()
      ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
      ..type = 'text/javascript';
    html.document.head!.append(script);
  } else {
    throw Exception('Google Maps API Key is missing');
  }
}

//Changing something

Future<void> main() async{
  //init flutter
  WidgetsFlutterBinding.ensureInitialized();

  //init .env
  await dotenv.load(fileName: ".env");
  
  //init firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  //run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage()
    );
  }
}


