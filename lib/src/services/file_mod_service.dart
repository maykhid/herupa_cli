import 'dart:io';

import 'package:herupa_cli/src/services/file_service.dart';
import 'package:herupa_cli/src/services/pubspec_service.dart';
import 'package:herupa_cli/src/templates/compiled_templates.dart';
import 'package:mustache_template/mustache.dart';
import 'package:recase/recase.dart';

class FileModService {
  final _fileService = FileService();

  Future<void> addGoRoute({
    required String workingDirectory,
    required String routeName,
  }) async {
    final appRoutesFilePath = '$workingDirectory/$kAppRoutesPath';

    final pubservice = PubspecService(workingDirectory: workingDirectory);
    final packageName = pubservice.appName;

    final lines = await _fileService.readFileAsLines(
      filePath: appRoutesFilePath,
    );

    final routesIndex = lines
        .indexWhere((line) => line.contains('static List<GoRoute> routes'));

    // add new route import
    final lastImportIndex = lines.lastIndexWhere(
        (line) => line.contains('''import 'package:$packageName'''));

    if (routesIndex != -1) {
      // Find the end of the routes list
      final endIndex =
          lines.indexWhere((line) => line.contains('];'), routesIndex);

      const newRoute = kAppRoute;

      final templateContent = Template(newRoute);

      final output = templateContent.renderString({
        'route': routeName.snakeCase,
        'route_pascal': routeName.pascalCase,
      });

      // Insert the new GoRoute string before the end of the routes list
      lines.insert(endIndex, output);
    }

    if (lastImportIndex != -1) {
      final endIndex = lines.indexWhere(
        (line) => line.contains('''import 'package:$packageName'''),
        lastImportIndex,
      );

      lines.insert(
        endIndex + 1,
        '''import 'package:$packageName/app/features/${routeName.snakeCase}/ui/views/screens/${routeName.snakeCase}_screen.dart'; ''',
      );
    }

    // Write the updated content back to the file
    await _fileService.writeStringFile(
      file: File(appRoutesFilePath),
      fileContent: lines.join('\n'),
    );
  }
}
