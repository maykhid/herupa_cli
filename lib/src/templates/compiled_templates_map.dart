import 'package:herupa_cli/src/templates/compiled_templates.dart';

const Map<String, String> kCompiledTemplates = {
  // path : content
  kMainPath: kMainContent,
  kAppPath: kAppContent,
  kAuthInterfacePath: kAuthInterface,
  kAuthImplPath: kAuthImpl,
  kAuthRepositoryPath: kAuthRepository,
  kUserDaoPath: kUserDao,
  kHiveUserDaoPath: kHiveUserDao,
  kUserPath: kUser,
  kAuthCubitPath: kAuthCubit,
  kAuthStatePath: kAuthState,
  kSignInCubitPath: kSignInCubit,
  kSignInStatePath: kSignInState,
  kSignInScreenPath: kSignInScreen,
  kHomeScreenPath: kHomeScreen,
  kAppButtonPath: kAppButton,
  kAppDialogPath: kAppDialog,
  kSizedContextPath: kSizedContext,
  kResultPath: kResult,
  kDiPath: kDi,
  kModulePath: kModule,
  kAppNavigationConfigPath: kAppNavigationConfig,
  kAppRoutesPath: kAppRoutes,
  kAnalysisOptionsPath: kAnalysisOptions,
};

const Map<String, String>  kFeatureCompiledTemplates = {
  kFooFeatureImplPath: kFooFeatureImpl,
  kFeatureInterfacePath: kFeatureInterface,
  kFeatureRepositoryPath: kFeatureRepository,
  kFeatureScreenPath: kFeatureScreen,
};
