import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/app.dart';
import 'package:smart_task_manager/bootstrap.dart';

void main() async {
  final node = UncontrolledProviderScope(
    container: await bootstrap(),
    child: const App(),
  );

  runApp(node);
}
