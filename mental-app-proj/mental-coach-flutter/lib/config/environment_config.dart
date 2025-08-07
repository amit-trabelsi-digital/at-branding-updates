import 'package:flutter/foundation.dart';
import 'package:color_simp/color_simp.dart';
import 'dart:io' show Platform;

enum Environment { dev, test, prod, local }

class EnvironmentConfig {
  static final EnvironmentConfig instance = EnvironmentConfig._internal();

  // Use 10.0.2.2 for Android emulators to connect to localhost on the host machine.
  // Use the machine's local network IP for physical devices.
  static String localIp = '192.168.0.153';
  EnvironmentConfig._internal();

  static Environment _environment = Environment.dev;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;

    // Automatically switch to local if running on localhost
    if (kIsWeb) {
      final String host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        _environment = Environment.local;
      }
    }

    // Corrected the logging to match the environment
    if (_environment == Environment.local) {
      "Working on local server, ip: $localIp".green.log();
      "If you have connection issues on a physical device, make sure the IP is correct."
          .yellow
          .log();
    } else {
      "Working on ${_environment.name.toUpperCase()} server".green.log();
    }
  }

  String get serverURL {
    switch (_environment) {
      case Environment.local:
        if (kIsWeb) {
          return "http://localhost:3000/api";
        } else if (Platform.isAndroid) {
          return "http://localhost:3000/api";
        } else if (Platform.isIOS) {
          return "http://localhost:3000/api";
        }
        // Fallback for physical devices
        return "http://$localIp:3000/api";
      case Environment.dev:
        return "https://dev-srv.eitanazaria.co.il/api";
      case Environment.test: // This points to the same as dev
        return "https://dev-srv.eitanazaria.co.il/api";
      case Environment.prod:
        return "https://app-srv.eitanazaria.co.il/api";
      // return "https://mntl-app.eitanazaria.co.il/api";
    }
  }
}
