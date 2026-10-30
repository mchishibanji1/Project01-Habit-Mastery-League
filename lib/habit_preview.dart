import 'package:flutter/material.dart';

import 'screens/dashboard.dart';

void main() {
  runApp(
    MaterialApp(
      home: DashboardScreen(),
      theme: ThemeData(primarySwatch: Colors.blue),
    ),
  );
}
