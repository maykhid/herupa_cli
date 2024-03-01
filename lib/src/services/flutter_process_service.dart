// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';
import 'dart:io';

import 'package:herupa_cli/src/services/log_service.dart';

class FlutterProcessService {
  /// Creates a new flutter app.
  ///
  /// Args:
  ///   appName (String): The name of the app that's going to be create.
  ///   shouldUseMinimalTempalte (bool): Uses minimal app template.
  ///   description (String): The description to use for your new Flutter project.
  ///   organization (String): The organization responsible for your new Flutter project.
  ///   platforms (List<String>): The platforms supported by this project.

  final log = ColorizedLogService();

  Future<void> runCreateApp({
    required String name,
    String? description,
    String? organization,
    List<String> platforms = const [],
  }) async {
    await _runProcess(
      programName: 'flutter',
      arguments: [
        'create',
        name,
        '-e',
        if (description != null) '--description="$description"',
        if (organization != null) '--org=$organization',
        if (platforms.isNotEmpty) '--platforms=${platforms.join(",")}',
      ],
    );
  }

  Future<void> runDartFix({
    String? workingDirectory,
    String? description,
    String? organization,
    List<String> platforms = const [],
  }) async {
    await _runProcess(
      programName: 'dart',
      arguments: ['fix', '--apply'],
      workingDirectory: workingDirectory,
    );
  }

  /// Run the `pub run build_runner build --delete-conflicting-outputs` command in the `appName` directory
  ///
  /// Args:
  ///   appName (String): The name of the app.
  Future<void> runBuildRunner({
    String? workingDirectory,
    bool shouldWatch = false,
    bool shouldDeleteConflictingOutputs = true,
  }) async {
    await _runProcess(
      programName: 'dart',
      arguments: [
        ...['run', 'build_runner'],
        if (shouldWatch) 'watch' else 'build',
        if (shouldDeleteConflictingOutputs) '--delete-conflicting-outputs',
      ],
      workingDirectory: workingDirectory,
    );
  }

  /// It runs the `flutter pub get` command in the app's directory
  ///
  /// Args:
  ///   appName (String): The name of the app.
  Future<void> runPubGet({String? appName}) async {
    await _runProcess(
      programName: 'flutter',
      arguments: ['pub', 'get'],
      workingDirectory: appName,
    );
  }

  /// Runs the dart format . command on the app's source code.
  ///
  /// Args:
  ///   appName (String): The name of the app.
  Future<void> runFormat({String? appName, String? filePath}) async {
    await _runProcess(
      programName: 'dart',
      arguments: [
        'format',
        filePath ?? '.',
        '-l',
        '80',
      ],
      workingDirectory: appName,
    );
  }

  /// It runs the `dart pub global activate` command in the app's directory
  Future<void> runPubGlobalActivate() async {
    await _runProcess(
      programName: 'dart',
      arguments: ['pub', 'global', 'activate', 'herupa_cli'],
    );
  }

  /// Runs the `dart pub global list` command and returns a list of strings
  /// representing packages with their version.
  Future<List<String>> runPubGlobalList() async {
    final output = <String>[];
    await _runProcess(
      programName: 'dart',
      arguments: ['pub', 'global', 'list'],
      verbose: false,
      handleOutput: (lines) async => output.addAll(lines),
    );

    return output;
  }

  /// Runs the flutter analyze command and returns the output as a list of lines.
  Future<List<String>> runAddPackages({
    required List<String> packages,
    String? appName,
  }) async {
    final output = <String>[];
    await _runProcess(
      programName: 'flutter',
      workingDirectory: appName,
      arguments: ['pub', 'add', ...packages],
      verbose: false,
      handleOutput: (lines) async => output.addAll(lines),
    );

    return output;
  }

  Future<List<String>> runAddDevPackages({
    required List<String> packages,
    String? appName,
  }) async {
    final output = <String>[];
    await _runProcess(
      programName: 'flutter',
      workingDirectory: appName,
      arguments: ['pub', 'add', '--dev', ...packages],
      verbose: false,
      handleOutput: (lines) async => output.addAll(lines),
    );

    return output;
  }

  /// Runs the flutter analyze command and returns the output as a list of lines.
  Future<List<String>> runAnalyze({String? appName}) async {
    final output = <String>[];
    await _runProcess(
      programName: 'flutter',
      arguments: ['analyze'],
      workingDirectory: appName,
      verbose: false,
      handleOutput: (lines) async => output.addAll(lines),
    );

    return output;
  }

  /// It runs a process and logs the output to the console when [verbose] is true.
  ///
  /// Args:
  ///   programName (String): The name of the program to run.
  ///   arguments (List<String>): The arguments to pass to the program. Defaults to const []
  ///   workingDirectory (String): The directory to run the command in.
  ///   verbose (bool): Determine when to log the output to the console.
  ///   handleOutput (Function): Function passed to handle the output.
  Future<void> _runProcess({
    required String programName,
    List<String> arguments = const [],
    String? workingDirectory,
    bool verbose = true,
    Future<void> Function(List<String> lines)? handleOutput,
  }) async {
    if (verbose) {
      final hasWorkingDirectory = workingDirectory != null;
      log.herupaOutput(
        message:
            'Running $programName ${arguments.join(' ')} ${hasWorkingDirectory ? 'in $workingDirectory/' : ''}...',
      );
    }

    try {
      final process = await Process.start(
        programName,
        arguments,
        workingDirectory: workingDirectory,
        runInShell: true,
      );

      final lines = <String>[];
      const lineSplitter = LineSplitter();
      await process.stdout.transform(utf8.decoder).forEach((output) {
        if (verbose) log.flutterOutput(message: output);

        if (handleOutput != null) {
          lines.addAll(
            lineSplitter
                .convert(output)
                .map((l) => l.trim())
                .where((l) => l.isNotEmpty)
                .toList(),
          );
        }
      });

      await handleOutput?.call(lines);

      final exitCode = await process.exitCode;

      if (verbose) logSuccessStatus(exitCode);
    } on ProcessException catch (e) {
      final message =
          'Command failed. Command executed: $programName ${arguments.join(' ')}\nException: ${e.message}';
      log.error(message: message);
      // locator<PosthogService>().logExceptionEvent(
      //   runtimeType: e.runtimeType.toString(),
      //   message: message,
      //   stackTrace: s.toString(),
      // );
    } catch (e) {
      final message =
          'Command failed. Command executed: $programName ${arguments.join(' ')}\nException: $e';
      log.herupaOutput(message: message);
      // locator<PosthogService>().logExceptionEvent(
      //   runtimeType: e.runtimeType.toString(),
      //   message: message,
      //   stackTrace: s.toString(),
      // );
    }
  }

  /// If the exit code is 0, log a success message, otherwise log an error message
  ///
  /// Args:
  ///   exitCode (int): The exit code of the command.
  ///
  void logSuccessStatus(int exitCode) {
    if (exitCode == 0) {
      log.success(
        message: 'Command complete. ExitCode: $exitCode',
      );
      return;
    }
    log.error(
      message: 'Command complete. ExitCode: $exitCode',
    );
  }
}
