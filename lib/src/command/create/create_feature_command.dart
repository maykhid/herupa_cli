import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:herupa_cli/src/services/file_mod_service.dart';
import 'package:herupa_cli/src/services/flutter_process_service.dart';
import 'package:herupa_cli/src/services/log_service.dart';
import 'package:herupa_cli/src/services/template_service.dart';

class CreateFeatureCommand extends Command<dynamic> {
  CreateFeatureCommand() {
    argParser
      ..addOption(
        'description',
        help: 'Explain the feature...',
      )
      ..addMultiOption(
        'layers',
        abbr: 'l',
        allowed: ['ui', 'data', 'domain'],
        help: 'Feature layers',
      );
  }

  @override
  String get description => 'Creates a new feature in project.';

  @override
  String get name => 'feature';

  final log = ColorizedLogService();
  final flutterProcess = FlutterProcessService();

  @override
  Future<void> run() async {
    final featureName = argResults!.rest.first;
    final workingDirectory =
        argResults!.rest.length > 1 ? argResults!.rest.last : null;
    final templateService = TemplateService();
    final fileModService = FileModService();
    // print(Directory.current.path);
    // print(featureName);
    // print(workingDirectory);
    await templateService.createFeatureTemplate(
      featureName: featureName,
      workingDirectory: workingDirectory ?? Directory.current.path,
    );

    await fileModService.addGoRoute(
      routeName: featureName,
      workingDirectory: workingDirectory ?? Directory.current.path,
    );
    await flutterProcess.runDartFix();
    await flutterProcess.runBuildRunner();
    await flutterProcess.runFormat();

    log.success(
      message: '\nGenerating $featureName feature, Done!',
    );
  }
}
