import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:herupa_cli/src/command/create/create_app_command.dart';
import 'package:herupa_cli/src/services/log_service.dart';

void main(List<String> arguments) {

  final log = ColorizedLogService();

  final runner = CommandRunner<dynamic>(
    'herupa',
    'A command line interface for setting up my custom Flutter application',
  )..addCommand(CreateAppCommand());

  log.success(
    message: '''

  ┌──────────────────────────────────────────────────────────────────┐
                   Welcome to the Herupā (ヘルパー) CLI               
  ├──────────────────────────────────────────────────────────────────┤
  │     A command line interface for setting up my custom            |
  |     Flutter application.                                         │
  └──────────────────────────────────────────────────────────────────┘
  ''',
  );

  try {
    runner.run(arguments);
  } catch (e) {
    log.error(message: e.toString());
    exit(2);
  }
}
