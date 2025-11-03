import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    String url;
    if (kIsWeb) {
      // Running in browser on laptop or mobile
      if (Uri.base.host == 'localhost') {
        url = "http://localhost:8080";
      } else {
        url = "http://192.168.0.240:8080"; // For web on other devices
      }
    } else {
      // Mobile app (Android/iOS)
      if (Platform.isAndroid) {
        // Android emulator uses 10.0.2.2 to access host machine's localhost
        url = "http://10.0.2.2:8080";
      } else if (Platform.isIOS) {
        // iOS simulator can use localhost directly
        url = "http://localhost:8080";
      } else {
        // Physical devices or other platforms
        url = "http://192.168.0.240:8080"; // Change to your computer's IP
      }
    }

    print(
      '🌐 API Base URL: $url (kIsWeb: $kIsWeb, Platform: ${!kIsWeb ? Platform.operatingSystem : "web"})',
    );
    return url;
  }
}
