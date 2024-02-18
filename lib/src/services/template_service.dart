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

    _log.herupaOutput(
      message: '\nFolders generated successfully 🥂',
      isBold: true,
    );
  }

  Future<void> _createAppFiles({required String workingDirectory}) async {
    _log.herupaOutput(
      message: '\nGenerating preset app files...',
      isBold: true,
    );

    for (final entry in kCompiledTemplates.entries) {
      final path = entry.key;
      final content = entry.value as String;

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

      await _fileService.writeStringFile(
        file: File('$workingDirectory/$path'),
        fileContent: output,
      );
    }

    _log.herupaOutput(
      message: '\nFiles generated successfully 🥂',
      isBold: true,
    );
  }

  String? _getVersion(String workingDirectory) {
    return PubspecService(workingDirectory: workingDirectory)
        .getDevDependencyVersion('very_good_analysis');
  }
}
