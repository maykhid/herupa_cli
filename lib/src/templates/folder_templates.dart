class FolderTemplate {
  FolderTemplate({
    required this.workingDirectory,
  });

  final String workingDirectory;

  Map<String, String> get predefinedFolderPaths =>
      _predefinedFolderPaths(workingDirectory);

  Map<String, String> customFeatureFolderPaths({required String featureName}) =>
      _customFeatureFolderPaths(featureName);

  String get lib => '$workingDirectory/lib';
  String get assets => '$workingDirectory/assets';
  String get app => '$lib/app';
  String get core => '$lib/core';
  String get features => '$app/features';
  String get shared => '$app/shared';

  Map<String, String> _customFeatureFolderPaths(
    String featureName,
  ) {
    final featurePath = '$features/$featureName';
    final layers = {
      featureName: featurePath,
      'data': '$featurePath/data',
      'ui': '$featurePath/ui',
      'domain': '$featurePath/domain',
    };
    final subfolders = {
      'views': '${layers['ui']}/views',
      'cubits': '${layers['ui']}/cubit',
      'usecases': '${layers['domain']}/usecases',
      'model': '${layers['data']}/model',
    };
    final subSubfolders = {
      'screens': '${subfolders['views']}/screens',
      'widgets': '${subfolders['views']}/widgets',
    };
    return layers..addAll(subfolders..addAll(subSubfolders));
  }

  Map<String, String> _predefinedFolderPaths(String workingDirectory) => {
        'assets': assets,
        'app': app,
        'core': core,
        'features': features,
        'shared': shared,

        'images': '$assets/images',
        'icons': '$assets/icons',

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
