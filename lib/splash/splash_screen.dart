import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:qr_earth/utils/constants.dart';
import 'package:qr_earth/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _whereToGo();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      barrierDismissible: false,
      showIgnore: false,
      showLater: false,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: Theme.of(context).colorScheme.surface,
          ),
          toolbarHeight: 0,
        ),
        body: Center(
          child: Image.asset(
            'assets/images/banner.png',
            width: 300,
          ),
        ),
      ),
    );
  }

  void _whereToGo() async {
    var sharedpref = await SharedPreferences.getInstance();
    var isLoggedIn = sharedpref.getBool(SharedPrefKeys.isLoggedIn) ?? false;
    var user = sharedpref.getString(SharedPrefKeys.userData);

    if (!isLoggedIn || user == null) {
      context.go('/login');
      return;
    }

    Global.user.setFromJson(jsonDecode(user));

    var response = await http.get(
      Uri.parse(
          "${AppConfig.serverBaseUrl}${ApiRoutes.userInfo}?user_id=${Global.user.id}"),
    );

    if (response.statusCode == HttpStatus.ok) {
      Global.user.setFromJson(jsonDecode(response.body));
      context.go('/home');
      return;
    }

    context.go('/login');
    return;
  }
}
