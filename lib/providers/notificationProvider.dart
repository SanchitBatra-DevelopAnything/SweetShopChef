import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class notificationProvider with ChangeNotifier {
  Future<void> getDeviceTokenToSendNotification(appType) async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    var deviceTokenToSendPushNotification = token.toString();

    var url = Uri.parse(
        'https://shastri-nagar-shop-app-default-rtdb.firebaseio.com/notificationTokens/' +
            appType +
            ".json");
    try {
      await http.patch(url,
          body: json.encode({"token": deviceTokenToSendPushNotification}));
      notifyListeners();
    } catch (error) {
      print("UNABLE TO PATCH NOTIFICATION TOKEN");
      print(error);
    }
  }
}
