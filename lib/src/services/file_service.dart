import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:herupa_cli/src/services/log_service.dart';

class FileService {
  final _log = ColorizedLogService();

  Future<void> writeStringFile({
    required File file,
    required String fileContent,
    bool verbose = false,
    FileModificationType type = FileModificationType.create,
    String? verboseMessage,
    bool forceAppend = false,
  }) async {
    if (!file.existsSync()) {
      if (type != FileModificationType.create) {
        _log.warn(message: 'File does not exist. Write it out');
      }
      await file.create(recursive: true);
    }

    await file.writeAsString(
      fileContent,
      mode: forceAppend ? FileMode.append : FileMode.write,
    );

    if (verbose) {
      _log.fileOutput(type: type, message: verboseMessage ?? '$file');
    }
  }

  Future<void> writeDataFile({
    required File file,
    required Uint8List fileContent,
    bool verbose = false,
    FileModificationType type = FileModificationType.create,
    String? verboseMessage,
    bool forceAppend = false,
  }) async {
    if (!file.existsSync()) {
      if (type != FileModificationType.create) {
        _log.warn(message: 'File does not exist. Write it out');
      }
      await file.create(recursive: true);
    }

    await file.writeAsBytes(
      fileContent,
      mode: forceAppend ? FileMode.append : FileMode.write,
    );

    if (verbose) {
      _log.fileOutput(type: type, message: verboseMessage ?? '$file');
    }
  }

  /// Delete a file at the given path
  ///
  /// Args:
  ///   filePath (String): The path to the file you want to delete.
  ///   verbose (bool): Determine if should log the action or not.
  Future<void> deleteFile({
    required String filePath,
    bool verbose = true,
  }) async {
    final file = File(filePath);
    await file.delete();
    if (verbose) {
      _log.fileOutput(type: FileModificationType.delete, message: '$file');
    }
  }

  /// It deletes all the files in a folder. and the folder itself.
  ///
  /// Args:
  ///   directoryPath (String): The path to the directory you want to delete.
  Future<void> deleteFolder({required String directoryPath}) async {
    final files = await getFilesInDirectory(directoryPath: directoryPath);
    await Future.forEach<FileSystemEntity>(files, (file) async {
      await file.delete();
      _log.fileOutput(type: FileModificationType.delete, message: '$file');
    });
    await Directory(directoryPath).delete();
  }

  /// Check if the file at [filePath] exists
  Future<bool> fileExists({required String filePath}) async {
    // ignore: avoid_slow_async_io
    return File(filePath).exists();
  }

  /// Reads the file at [filePath] on disk and returns as String
  Future<String> readFileAsString({
    required String filePath,
  }) {
    return File(filePath).readAsString();
  }

  /// Reads the file at [filePath] and returns its data as bytes
  Future<Uint8List> readAsBytes({required String filePath}) {
    return File(filePath).readAsBytes();
  }

  /// Read the file at the given path and return the contents as a list of strings, one string per
  /// line.
  ///
  /// Args:
  ///   filePath (String): The path to the file to read.
  ///
  /// Returns:
  ///   A Future<List<String>>
  Future<List<String>> readFileAsLines({
    required String filePath,
  }) {
    return File(filePath).readAsLines();
  }

  // Future<void> removeSpecificFileLines({
  //   required String filePath,
  //   required String removedContent,
  //   String type = kTemplateNameView,
  // }) async {
  //   final recaseName = ReCase('$removedContent $type');
  //   if (type == kTemplateNameService) {
  //     await removeTestHelperFunctionFromFile(
  //       filePath: filePath,
  //       serviceName: recaseName.pascalCase,
  //     );
  //   }
  //   final var fileLines = await readFileAsLines(filePath: filePath);
  //   fileLines.removeWhere((line) => line.contains('/${recaseName.snakeCase}'));
  //   fileLines.removeWhere((line) => line.contains(' ${recaseName.pascalCase}'));
  //   await writeStringFile(
  //     file: File(filePath),
  //     fileContent: fileLines.join('\n'),
  //     type: FileModificationType.Modify,
  //     verbose: true,
  //     verboseMessage: 'Removed ${recaseName.pascalCase} from $filePath',
  //   );
  // }

  /// Removes [linesNumber] on the file at [filePath].
  Future<void> removeLinesOnFile({
    required String filePath,
    required List<int> linesNumber,
  }) async {
    final fileLines = await readFileAsLines(filePath: filePath);

    for (final line in linesNumber) {
      fileLines.removeAt(line - 1);
    }

    await writeStringFile(
      file: File(filePath),
      fileContent: fileLines.join('\n'),
      type: FileModificationType.modify,
    );
  }

  Future<void> removeTestHelperFunctionFromFile({
    required String filePath,
    required String serviceName,
  }) async {
    var fileString = await readFileAsString(filePath: filePath);
    fileString = fileString.replaceAll(
      RegExp(
        'Mock$serviceName getAndRegister$serviceName[(][)] {.*?}',
        caseSensitive: false,
        dotAll: true,
        multiLine: true,
      ),
      '',
    );
    await writeStringFile(
      file: File(filePath),
      fileContent: fileString,
      type: FileModificationType.modify,
    );
  }

  /// Gets all files in a given directory
  Future<List<FileSystemEntity>> getFilesInDirectory({
    required String directoryPath,
  }) async {
    final directory = Directory(directoryPath);
    final allFileEntities = await _listDirectoryContents(directory);
    return allFileEntities.toList();
  }

  Future<List<String>> getFoldersInDirectory({
    required String directoryPath,
  }) async {
    final directory = Directory(directoryPath);
    final allFileEntities =
        await _listDirectoryContents(directory, recursive: false);
    return allFileEntities.whereType<Directory>().map((e) => e.path).toList();
  }

  Future<List<FileSystemEntity>> _listDirectoryContents(
    Directory dir, {
    bool recursive = true,
  }) {
    final files = <FileSystemEntity>[];
    final completer = Completer<List<FileSystemEntity>>();
    dir.list(recursive: recursive).listen(
          files.add,
          // should also register onError
          onDone: () => completer.complete(files),
        );
    return completer.future;
  }
}

// enum for file modification types
enum FileModificationType {
  append,
  create,
  modify,
  delete,
}
