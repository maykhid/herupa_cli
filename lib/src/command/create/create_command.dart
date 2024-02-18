import 'package:args/command_runner.dart';

import 'package:herupa_cli/src/command/create/create_app_command.dart';

/// A command with subcommands that allows you to create / scaffold
/// different parts of the stacked application
class CreateCommand extends Command<dynamic> {
  CreateCommand() {
    addSubcommand(CreateAppCommand());
  }

  @override
  String get description => 'The Creation Module';

  @override
  String get name => 'create';
}
