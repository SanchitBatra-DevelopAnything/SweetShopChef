import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sweet_shop/customOrderDetail.dart';
import 'package:sweet_shop/providers/notificationProvider.dart';
import 'package:sweet_shop/providers/orderProvider.dart';
import 'package:sweet_shop/regularOrderDetail.dart';
import 'package:sweet_shop/workerType.dart';
import 'package:provider/provider.dart';

import 'myOrders.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OrdersProvider()),
        ChangeNotifierProvider(
          create: (context) => notificationProvider(),
        )
      ],
      child: MaterialApp(
        title: 'Sweet Shop',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.green,
          hintColor: Colors.white,
        ),
        routes: {
          '/': (context) => WorkerType(),
          '/orders': (context) => MyOrders(),
          '/regDetail': (context) => RegularOrderDetail(),
          "/customDetail": (context) => CustomOrderDetail(),
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
