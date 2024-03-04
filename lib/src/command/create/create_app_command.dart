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
  final log = ColorizedLogService();

  @override
  String get description =>
      'Creates my template application with all the basics setup.';

  @override
  String get name => 'app';

  @override
  Future<void> run() async {
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

    try {
      if (Platform.isMacOS) {
        stdout
          ..writeln('Would you like to open your new flutter app?')
          ..write('[y/n]: ');
        final opt = stdin.readLineSync()?.toLowerCase().trim();

        if (opt == 'y' || opt == 'yes') {
          stdout
            ..writeln('Launch with VSCode, Android Studio or IntelliJ...')
            ..write('[V/A/I]: ');

          final ide = stdin.readLineSync()?.toLowerCase().trim();

          if (ide == 'i') {
            await _launchProjectOnIntellij(
              '${Directory.current.path}/$workingDirectory',
            );
          } else if (ide == 'a') {
            await _launchProjectOnAndroidStudio(
              '${Directory.current.path}/$workingDirectory',
            );
          } else {
            await _launchProjectOnVscode(workingDirectory);
          }
        } else {
          if (opt != 'n' && opt != 'No' && opt != 'y' && opt != 'yes') {
            log.herupaOutput(message: 'Not a valid option.');
          }
          log.herupaOutput(
            message:
                '''Okay. You can find your app [$workingDirectory] in your current working directory ${Directory.current.path}''',
          );
        }
      } else {
        // Launching on other platforms is not supported yet.
      }
    } catch (e) {
      log.error(message: e.toString());
    }
  }

  Future<void> _launchProjectOnAndroidStudio(
    String projectPath,
  ) async {
    try {
      log.herupaOutput(message: 'Launching Android Studio...');
      await Process.start('open', ['-a', 'Android Studio', projectPath]);
    } catch (e) {
      log.error(message: e.toString());
    }
  }

  Future<void> _launchProjectOnVscode(String projectPath) async {
    try {
      log.herupaOutput(message: 'Launching VSCode...');
      await Process.start('code', [projectPath]);
    } catch (e) {
      log.error(message: e.toString());
    }
  }

  Future<void> _launchProjectOnIntellij(String projectPath) async {
    try {
      log.herupaOutput(message: 'Launching IntelliJ...');
      await Process.start(
        'open',
        ['-a', 'IntelliJ IDEA', projectPath],
      );
    } catch (e) {
      log.error(message: e.toString());
    }
  }
}
