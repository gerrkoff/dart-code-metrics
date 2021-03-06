import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:dart_code_metrics/src/analyzer_plugin/analyzer_plugin.dart';

void start(Iterable<String> _, SendPort sendPort) {
  ServerPluginStarter(MetricsAnalyzerPlugin(PhysicalResourceProvider.INSTANCE))
      .start(sendPort);
}
