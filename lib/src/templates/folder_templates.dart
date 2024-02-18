class FolderTemplate {
  FolderTemplate({
    required this.workingDirectory,
  });

  final String workingDirectory;

  Map<String, String> get predefinedFolderPaths =>
      _predefinedFolderPaths(workingDirectory);

  String get lib => '$workingDirectory/lib';
  String get app => '$lib/app';
  String get core => '$lib/core';
  String get features => '$app/features';
  String get shared => '$app/shared';

  Map<String, String> _predefinedFolderPaths(String workingDirectory) => {
        'app': app,
        'core': core,
        'features': features,
        'shared': shared,

        // features subfolders
        'auth': '$features/auth',
        'home': '$features/home',

        // shared subfolders
        'ui': '$shared/ui',
        'utils': '$shared/utils',

        /// core subfolders
        'core-data': '$core/data',
        'core-di': '$core/di',
        'core-navigation': '$core/navigation',
      };
}
