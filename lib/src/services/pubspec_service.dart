import 'dart:io';

import 'package:herupa_cli/src/services/log_service.dart';
import 'package:yaml/yaml.dart';

// import 'package:pubspec_yaml/pubspec_yaml.dart';

/// Provides functionality to interact with the pubspec in the current project
class PubspecService {
  PubspecService({required String workingDirectory})
      : _workingDirectory = workingDirectory;

  /// The path of the `pubspec.yaml` file for the current project
  final String _workingDirectory;
  final _log = ColorizedLogService();

  String get pubspecContent =>
      File('$_workingDirectory/pubspec.yaml').readAsStringSync();

  dynamic get pubspecYaml => loadYaml(pubspecContent);

  dynamic get getAlldependencies => pubspecYaml['dependencies'];

  dynamic get getAllDevDependencies => pubspecYaml['dev_dependencies'];

  bool hasDependency(String dependencyName) =>
      (getAlldependencies as Map).containsKey(dependencyName);

  bool hasDevDependency(String dependencyName) =>
      (getAllDevDependencies as Map).containsKey(dependencyName);

  String? getDependencyVersion(String dependencyName) {
    if (hasDependency(dependencyName)) {
      final dependencyVersion =
          (getAlldependencies as Map)[dependencyName] as String;

      return dependencyVersion.replaceFirst('^', '');
    } else {
      _log.info(message: 'Dependency does not exist!');
      return null;
    }

  }
  String? getDevDependencyVersion(String dependencyName) {
    if (hasDevDependency(dependencyName)) {
      final dependencyVersion =
          (getAllDevDependencies as Map)[dependencyName] as String;

      return dependencyVersion.replaceFirst('^', '');
    } else {
      _log.info(message: 'Dependency does not exist!');
      return null;
    }
  }
}
