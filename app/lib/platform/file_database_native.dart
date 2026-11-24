import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

QueryExecutor openFileDatabase(File file) => NativeDatabase(file);
