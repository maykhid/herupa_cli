import 'dart:io';

import 'package:herupa_cli/src/services/file_service.dart';
import 'package:herupa_cli/src/services/log_service.dart';
import 'package:herupa_cli/src/services/pubspec_service.dart';
import 'package:herupa_cli/src/templates/compiled_templates_map.dart';
import 'package:herupa_cli/src/templates/folder_templates.dart';
import 'package:mustache_template/mustache.dart';
import 'package:recase/recase.dart';

class TemplateService {
  final _fileService = FileService();
  final _log = ColorizedLogService();

  /// Create default template for a Flutter app
  Future<void> createNewAppTemplate({required String workingDirectory}) async {
    await _createAppFolders(workingDirectory: workingDirectory);
    await _createAppFiles(workingDirectory: workingDirectory);
  }

  Future<void> createFeatureTemplate({
    required String featureName,
    String? workingDirectory,
  }) async {
    await _createFeatureFolders(
      featureName: featureName,
      workingDirectory: workingDirectory,
    );
    await _createFeatureFiles(
      workingDirectory: workingDirectory!,
      featureName: featureName,
    );
  }

  Future<void> _createAppFolders({required String workingDirectory}) async {
    _log.herupaOutput(
      message: '\nGenerating working app folders...',
      isBold: true,
    );
    final folderTemplate = FolderTemplate(workingDirectory: workingDirectory);

    for (final entry in folderTemplate.predefinedFolderPaths.entries) {
      final path = entry.value;
      await Directory(path).create();
    }

    _log.success(
      message: '\nFolders generated successfully 🥂',
    );
  }

  Future<void> _createAppFiles({required String workingDirectory}) async {
    _log.herupaOutput(
      message: '\nGenerating preset app files...',
      isBold: true,
    );

    for (final entry in kCompiledTemplates.entries) {
      final path = entry.key;
      final content = entry.value;

      final template = Template(content);
      var version = '5.1.0'; // default version

      // try to get very good analysis version
      // only when current file is 'analysis_options.yaml'
      //
      if (path == 'analysis_options.yaml') {
        version = _getVersion(workingDirectory) ?? version;
      }

      final output = template.renderString({
        'packageName': workingDirectory,
        'appName': ReCase(workingDirectory).pascalCase,
        'vga_version': version,
      });

      // add assets to pub if path is pubspec.yaml
      if (path != 'pubspec.yaml') {
        await _fileService.writeStringFile(
          file: File('$workingDirectory/$path'),
          fileContent: output,
        );
      } else {
        await _fileService.writeStringFile(
          file: File('$workingDirectory/$path'),
          fileContent: output,
          forceAppend: true,
        );
      }
    }

    _log.success(
      message: '\nFiles generated successfully 🥂',
    );
  }

  String? _getVersion(String workingDirectory) {
    return PubspecService(workingDirectory: workingDirectory)
        .getDevDependencyVersion('very_good_analysis');
  }

  Future<void> _createFeatureFolders({
    required String featureName,
    String? workingDirectory,
  }) async {
    final dir = workingDirectory ?? Directory.current.path;
    final folderTemplate = FolderTemplate(workingDirectory: dir);

    _log.herupaOutput(
      message: '\nCreating feature $featureName layers...',
      isBold: true,
    );
    for (final i in folderTemplate
        .customFeatureFolderPaths(featureName: featureName)
        .entries) {
      await Directory(i.value).create(recursive: true);
      _log.herupaOutput(
        message: '\nCreated $featureName ${i.key} folder at ${i.value}',
        isBold: true,
      );
    }

    _log.success(
      message: '\nCreating feature $featureName layers. Done🥂',
    );
  }

  Future<void> _createFeatureFiles({
    required String workingDirectory,
    required String featureName,
  }) async {
    _log.herupaOutput(
      message: '\nGenerating feature $featureName files...',
      isBold: true,
    );

    final pubservice = PubspecService(workingDirectory: workingDirectory);
    final packageName = pubservice.appName;
    for (final entry in kFeatureCompiledTemplates.entries) {
      final path = entry.key;
      final content = entry.value;

      final templateContent = Template(content);
      final templatePath = Template(path);

      final output = templateContent.renderString({
        'feature': featureName.pascalCase,
        'feature_param_case': featureName.camelCase,
        'feature_path_case': featureName.snakeCase,
        'packageName': packageName,
      });

      // print('template_serv'.case);

      final templatePathOutput = templatePath.renderString({
        'feature_path_case': featureName.snakeCase,
      });

      await _fileService.writeStringFile(
        file: File('$workingDirectory/$templatePathOutput'),
        fileContent: output,
      );
    }

    _log.success(
      message: '\nDone generating feature $featureName files 🥂',
    );
  }
}
