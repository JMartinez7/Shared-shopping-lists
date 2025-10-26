import 'package:flutter/material.dart';

class AppTheme {
  ThemeData appTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.greenAccent,
    brightness: Brightness.dark,
  );

  ThemeData getTheme() => personalizeAppTheme(appTheme);

  ThemeData personalizeAppTheme(ThemeData appTheme) {
    return appTheme.copyWith(
      appBarTheme: appTheme.appBarTheme.copyWith(
        backgroundColor: appTheme.colorScheme.inversePrimary.withAlpha(200),
        foregroundColor: appTheme.colorScheme.onSurface,
        iconTheme: appTheme.iconTheme.copyWith(
          color: appTheme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
