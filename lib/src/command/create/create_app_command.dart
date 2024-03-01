import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:herupa_cli/src/services/flutter_process_service.dart';
import 'package:herupa_cli/src/services/log_service.dart';
import 'package:herupa_cli/src/services/template_service.dart';

class CreateAppCommand extends Command<dynamic> {
  CreateAppCommand() {
    argParser
      ..addOption(
        'description',
        help: 'Explain the app..',
      )
      ..addOption(
        'org',
        help: 'App organization',
      )
      ..addMultiOption(
        'platforms',
        allowed: ['ios', 'android', 'windows', 'linux', 'macos', 'web'],
        help: 'Supported Platforms',
      );
  }

  @override
  String get description =>
      'Creates my template application with all the basics setup.';

  @override
  String get name => 'app';

  @override
  Future<void> run() async {
    final log = ColorizedLogService();
    final workingDirectory = argResults!.rest.first;
    // final appName = workingDirectory.split('/').last;
    // final templateType = argResults!['template'];

    final flutterProcess = FlutterProcessService();
    final templateService = TemplateService();

    await flutterProcess.runCreateApp(
      name: workingDirectory,
      description: argResults!['description'] as String?,
      organization: argResults!['org'] as String?,
      platforms: argResults!['platforms'] as List<String>,
    );

    log.herupaOutput(
      message: '\nSprinkling love with Herupā 💕... ',
      isBold: true,
    );

    await flutterProcess.runAddPackages(
      packages: [
        'flutter_bloc',
        'gap',
        'get_it',
        'hive_flutter',
        'injectable',
        'go_router',
        'path',
        'path_provider',
        'equatable',
        'toastification',
      ]..sort(),
      appName: workingDirectory,
    );

    await flutterProcess.runAddDevPackages(
      packages: [
        'very_good_analysis',
        'build_runner',
        'injectable_generator',
        'hive_generator',
      ]..sort(),
      appName: workingDirectory,
    );

    await templateService.createNewAppTemplate(
      workingDirectory: workingDirectory,
    );

    await flutterProcess.runPubGet(appName: workingDirectory);
    await flutterProcess.runBuildRunner(workingDirectory: workingDirectory);

    await flutterProcess.runFormat(appName: workingDirectory);

    stdout
      ..writeln('Would you like to open your new flutter app?')
      ..write('[y/n]: ');
    final opt = stdin.readLineSync()?.toLowerCase().trim();

    if (opt == 'y' || opt == 'yes') {
      await Process.start('code', [workingDirectory]);
    } else {
      log.herupaOutput(
        message:
            '''Okay. You can find your app [$workingDirectory] in your current working directory ${Directory.current.path}''',
      );
    }
  }
}
