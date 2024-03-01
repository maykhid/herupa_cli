const kMainPath = 'lib/main.dart';
const kMainContent = '''
import 'package:flutter/material.dart';
import 'package:{{packageName}}/app/app.dart';
import 'package:{{packageName}}/app/features/auth/data/model/user.dart';
import 'package:{{packageName}}/core/di/di.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  await setup();
  runApp(const {{appName}}App());
}

// ignore:  inference_failure_on_function_return_type, always_declare_return_types, type_annotate_public_apis
setup() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final dbPath = join(dir.path, '.db.hive');
  await Hive.initFlutter(dbPath);

  Hive.registerAdapter(UserAdapter());

  await initDependencies();
}

  ''';

const kPubspecPath = 'pubspec.yaml';
const kPubspec = '''
  assets:
    - assets/images/
    - assets/icons/
''';

const kAppPath = 'lib/app/app.dart';
const kAppContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{packageName}}/app/features/auth/data/authentication_repository.dart';
import 'package:{{packageName}}/app/features/auth/ui/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:{{packageName}}/core/di/di.dart';
import 'package:{{packageName}}/core/navigation/app_navigation_config.dart';

class {{appName}}App extends StatelessWidget {
  const {{appName}}App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationCubit>(
      create: (context) => AuthenticationCubit(
        authenticationRepository: locator<AuthenticationRepository>(),
      ),
      child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              useMaterial3: false,
            ),
            routerConfig:
                AppRouterConfig.goRouter(context.read<AuthenticationCubit>()),
          );
        },
      ),
    );
  }
}

  ''';

/// --- features content --- ///
///
///* --- authentication

/// --- data
const kAuthInterfacePath =
    'lib/app/features/auth/data/authentication_interface.dart';
const kAuthInterface = '''
import 'package:{{packageName}}/app/features/auth/data/model/user.dart';

abstract class IAuthentication {
  Future<void> signIn();
  Future<void> signOut();
  User get authenticatedUser;
}

''';

const kAuthImplPath = 'lib/app/features/auth/data/foo_authentication.dart';
const kAuthImpl = '''
// ignore_for_file: inference_failure_on_instance_creation

import 'package:{{packageName}}/app/features/auth/data/authentication_interface.dart';
import 'package:{{packageName}}/app/features/auth/data/model/user.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: IAuthentication)
class FooAuthentication extends IAuthentication {
  //
  final _duration = const Duration(seconds: 3);

  User _authenticatedUser = User.empty;

  @override
  User get authenticatedUser => _authenticatedUser;

  @override
  Future<void> signIn() async {
    try {
      _authenticatedUser = const User(id: '01', name: 'foo');
      await Future.delayed(_duration);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.delayed(_duration);
    } catch (e) {
      throw Exception(e);
    }
  }
}

''';

const kAuthRepositoryPath =
    'lib/app/features/auth/data/authentication_repository.dart';
const kAuthRepository = '''
import 'package:{{packageName}}/app/features/auth/data/authentication_interface.dart';
import 'package:{{packageName}}/app/features/auth/data/dao/user_dao.dart';
import 'package:{{packageName}}/app/features/auth/data/model/user.dart';
import 'package:{{packageName}}/core/data/model/result.dart';
import 'package:injectable/injectable.dart';

@singleton
class AuthenticationRepository {
  AuthenticationRepository({
    required IAuthentication authenticationInterface,
    required UserDao userDao,
  })  : _authenticationInterface = authenticationInterface,
        _userDao = userDao;

  final IAuthentication _authenticationInterface;
  final UserDao _userDao;

  Future<Result<void>> signIn() async {
    try {
      final response = await _authenticationInterface.signIn();
      final user = _authenticationInterface.authenticatedUser;

      if (user.isNotEmpty) {
        _userDao.writeUser(user);
      } else {
        throw Exception('An error occured: No valid user!');
      }

      return Result.success(response);
    } catch (e) {
      return Result.failure(errorMessage: e.toString());
    }
  }

  Future<Result<void>> signOut() async {
    try {
      final response = await _authenticationInterface.signOut();
      _userDao.deleteUser();
      return Result.success(response);
    } catch (e) {
      return Result.failure(errorMessage: e.toString());
    }
  }

  User get user {
    if (_userDao.userExists) {
      return _userDao.readUser();
    }
    return User.empty;
  }
}

''';

/// dao
const kUserDaoPath = 'lib/app/features/auth/data/dao/user_dao.dart';
const kUserDao = '''
    import 'package:{{packageName}}/app/features/auth/data/model/user.dart';

    abstract class UserDao {
      void writeUser(User user);
      void deleteUser();
      bool get userExists;
      User readUser();
    }

''';

const kHiveUserDaoPath = 'lib/app/features/auth/data/dao/hive_user_dao.dart';
const kHiveUserDao = '''
import 'package:{{packageName}}/app/features/auth/data/dao/user_dao.dart';
import 'package:{{packageName}}/app/features/auth/data/model/user.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: UserDao)
class HiveUserDao implements UserDao {
  HiveUserDao({
    required Box<User> userBox,
  }) : _userBox = userBox;

  final Box<User> _userBox;

  static const String _key = '__user__key__';

  @override
  User readUser() {
    if (_userBox.isEmpty) {
      return User.empty;
    }
    return _userBox.get(_key) ?? User.empty;
  }

  @override
  void writeUser(User authenticatedUser) =>
      _userBox.put(_key, authenticatedUser);

  @override
  void deleteUser() => _userBox.delete(_key);

  @override
  bool get userExists => _userBox.isNotEmpty;
}

''';

/// model
const kUserPath = 'lib/app/features/auth/data/model/user.dart';
const kUser = '''
      import 'package:equatable/equatable.dart';
      import 'package:hive_flutter/hive_flutter.dart';

      part 'user.g.dart';

      @HiveType(typeId: 0)
      class User with EquatableMixin {
        const User({
          required this.id,
          this.name,
          this.email,
        });

        @HiveField(0)
        final String id;

        @HiveField(1)
        final String? name;

        @HiveField(2)
        final String? email;

        /// Empty user which represents an unauthenticated user.
        static const empty = User(id: '');

        /// Convenience getter to determine whether the current user is empty.
        bool get isEmpty => this == User.empty;

        /// Convenience getter to determine whether the current user is not empty.
        bool get isNotEmpty => this != User.empty;

        @override
        List<Object?> get props => [id, name, email];
      }

''';

/// --- ui
///
/// cubits
const kAuthCubitPath =
    'lib/app/features/auth/ui/cubit/authentication_cubit/authentication_cubit.dart';
const kAuthCubit = '''

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{packageName}}/app/features/auth/data/authentication_repository.dart';
import 'package:{{packageName}}/app/features/auth/data/model/user.dart';
import 'package:{{packageName}}/core/di/di.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({AuthenticationRepository? authenticationRepository})
      : _authenticationRepository =
            authenticationRepository ?? locator<AuthenticationRepository>(),
        super(
          authenticationRepository!.user.isNotEmpty
              ? AuthenticatedState(authenticationRepository.user)
              : const UnauthenticatedState(),
        );

  final AuthenticationRepository _authenticationRepository;

  void updateUserState() {
    if (_authenticationRepository.user.isEmpty) {
      emit(const UnauthenticatedState());
    } else {
      emit(AuthenticatedState(_authenticationRepository.user));
    }
  }

  Future<void> signOut() async {
    await _authenticationRepository.signOut();
    emit(const UnauthenticatedState());
  }
}

''';

const kAuthStatePath =
    'lib/app/features/auth/ui/cubit/authentication_cubit/authentication_state.dart';
const kAuthState = '''
      part of 'authentication_cubit.dart';

      sealed class AuthenticationState extends Equatable {
        const AuthenticationState(this.user);
        @override
        List<Object?> get props => [user];

        final User user;
      }

      class AuthenticatedState extends AuthenticationState {
        const AuthenticatedState(super.user);
      }

      class UnauthenticatedState extends AuthenticationState {
        const UnauthenticatedState() : super(User.empty);
      }

''';

const kSignInCubitPath =
    'lib/app/features/auth/ui/cubit/sign_in_cubit/sign_in_cubit.dart';
const kSignInCubit = '''
      import 'package:equatable/equatable.dart';
      import 'package:flutter_bloc/flutter_bloc.dart';
      import 'package:{{packageName}}/app/features/auth/data/authentication_repository.dart';
      import 'package:{{packageName}}/app/features/auth/ui/cubit/authentication_cubit/authentication_cubit.dart';
      import 'package:{{packageName}}/core/di/di.dart';

      part 'sign_in_state.dart';

      class SignInCubit extends Cubit<SignInState> {
        SignInCubit({
          required AuthenticationCubit authenticationCubit,
          AuthenticationRepository? authenticationRepository,
        })  : _authenticationRepository =
                  authenticationRepository ?? locator<AuthenticationRepository>(),
              _authenticationCubit = authenticationCubit,
              super(IdleState());

        final AuthenticationRepository _authenticationRepository;
        final AuthenticationCubit _authenticationCubit;

        Future<void> signIn() async {
          emit(SigningInState());
          final response = await _authenticationRepository.signIn();

          if (response.isFailure) {
            emit(ErrorState(errorMessage: response.errorMessage));
          } else {
            _authenticationCubit.updateUserState();
            emit(SignedInState());
          }
        }
      }

''';

const kSignInStatePath =
    'lib/app/features/auth/ui/cubit/sign_in_cubit/sign_in_state.dart';
const kSignInState = '''
      part of 'sign_in_cubit.dart';

      sealed class SignInState extends Equatable {
        const SignInState();
        @override
        List<Object?> get props => [];
      }

      class SigningInState extends SignInState {}

      class SignedInState extends SignInState {}

      class IdleState extends SignInState {}

      class ErrorState extends SignInState {
        const ErrorState({this.errorMessage});

        final String? errorMessage;
      }

''';

// views
const kSignInScreenPath =
    'lib/app/features/auth/ui/views/screens/sign_in_screen.dart';
const kSignInScreen = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:{{packageName}}/app/features/auth/ui/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:{{packageName}}/app/features/auth/ui/cubit/sign_in_cubit/sign_in_cubit.dart';
import 'package:{{packageName}}/app/shared/ui/app_button.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<SignInCubit>(
        create: (context) => SignInCubit(
          authenticationCubit: context.read<AuthenticationCubit>(),
        ),
        child: const SignInView(),
      ),
    );
  }
}

class SignInView extends StatelessWidget {
  const SignInView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Herupā Template',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),

          //
          const Gap(5),

          //
          const Text(
            'Generated with Herupā',
            style: TextStyle(color: Colors.grey),
          ),

          const Gap(25),

          BlocBuilder<SignInCubit, SignInState>(
            builder: (context, state) {
              return AppButton(
                text: 'Sign In',
                backgroundColor: Colors.black,
                onPressed: () {
                  context.read<SignInCubit>().signIn();
                },
                isLoading: state is SigningInState,
              );
            },
          ),
        ],
      ),
    );
  }
}

''';

/// * --- home
/// --- ui
const kHomeScreenPath = 'lib/app/features/home/ui/home_screen.dart';
const kHomeScreen = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{packageName}}/app/features/auth/ui/cubit/authentication_cubit/authentication_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthenticationCubit>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: authCubit.signOut,
        child: const Icon(
          Icons.exit_to_app_rounded,
        ),
      ),
      body: const Center(
        child: Text(
          'Life is better with a Herupā!',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

''';

/// --- shared content --- ///
///
/// --- ui
const kAppButtonPath = 'lib/app/shared/ui/app_button.dart';
const kAppButton = '''
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    super.key,
  });

  final String text;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Widget? icon;
  final bool isLoading;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon ?? const SizedBox.square(dimension: 0,),
      label: isLoading
          ? const CupertinoActivityIndicator(
              color: Colors.white,
            )
          : Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(width ?? 240, height ?? 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? 12,
          ), // Set border radius here
        ),
        backgroundColor: backgroundColor ??
            Colors.black, // Change the color for Google button
      ),
    );
  }
}

''';

const kAppDialogPath = 'lib/app/shared/ui/app_dialog.dart';
const kAppDialog = '''
    import 'dart:ui';

    import 'package:flutter/material.dart';

    class AppDialog {
      // pop dialog
      static void showAppDialog(
        BuildContext context,
        Widget widget, [
        Color? backgroundColor,
      ]) {
        showDialog<void>(
          barrierColor: Colors.transparent,
          context: context,
          // barrierDismissible: true,
          builder: (context) => BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 2,
              sigmaY: 2,
            ), // blurs the area underneath the modal
            child: Dialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: widget,
              ),
            ),
          ),
        );
      }
    }

''';

/// -- asset
const kAppImagesPath = 'lib/app/shared/ui/app_images.dart';
const kAppImages = '''
class AppImages {
  static const String dummyImage =
      '';
}
''';

const kAppIconsPath = 'lib/app/shared/ui/app_icons.dart';
const kAppIcons = '''
class AppIcons {
  static const icActivity = '';
}
''';

const kAppColorsPath = 'lib/app/shared/ui/app_colors.dart';
const kAppColors = '''
import 'package:flutter/material.dart';

class AppColors {
  static const Color black = Color(0xFF222222);
}
''';

/// --- utils
const kSizedContextPath = 'lib/app/shared/utils/sized_context.dart';
const kSizedContext = '''
      import 'dart:math';

      import 'package:flutter/material.dart';

      extension SizedContext on BuildContext {
        /// Returns same as MediaQuery.of(context)
        MediaQueryData get _mediaQuery => MediaQuery.of(this);

        /// Returns if Orientation is landscape
        bool get isLandscape => _mediaQuery.orientation == Orientation.landscape;

        /// Returns same as MediaQuery.of(context).size
        Size get size => _mediaQuery.size;

        /// Returns same as MediaQuery.of(context).size.width
        double get width => size.width;

        /// Returns same as MediaQuery.of(context).height
        double get height => size.height;

        /// Returns diagonal screen pixels
        double get diagonal {
          final s = size;
          return sqrt((s.width * s.width) + (s.height * s.height));
        }
      }

''';

/// --- core content --- ///
///
/// --- data
const kResultPath = 'lib/core/data/model/result.dart';
const kResult = '''
    class Result<T> {
      Result._(this.data);

      factory Result.success(T? data) = _Success<T>;

      factory Result.failure({String? errorMessage, T? data}) = _Failure<T>;

      bool get isSuccess => this is _Success<T>;
      bool get isFailure => this is _Failure<T?>;

      final T? data;

      // Getter method to access the error message
      String? get errorMessage {
        if (isFailure) {
          return (this as _Failure).errorMessage;
        }
        return null;
      }
    }

    class _Success<T> extends Result<T> {
      _Success(super.data) : super._();
    }

    class _Failure<T> extends Result<T> {
      _Failure({this.errorMessage, T? data}) : super._(data);

      @override
      final String? errorMessage;
    }
  
''';

/// --- di
const kDiPath = 'lib/core/di/di.dart';
const kDi = '''
import 'package:get_it/get_it.dart';
import 'package:{{packageName}}/core/di/di.config.dart';
import 'package:injectable/injectable.dart';

final locator = GetIt.instance;

@injectableInit
Future<void> initDependencies() async => locator.init();

''';

const kModulePath = 'lib/core/di/module.dart';
const kModule = '''
      import 'package:{{packageName}}/app/features/auth/data/model/user.dart';
      import 'package:hive_flutter/hive_flutter.dart';
      import 'package:injectable/injectable.dart';

      @module
      abstract class RegisterModule {
        // @singleton
        @preResolve
        Future<Box<User>> get userBox => Hive.openBox<User>('userBox');
      }

''';

/// --- navigation
const kAppNavigationConfigPath =
    'lib/core/navigation/app_navigation_config.dart';
const kAppNavigationConfig = '''
import 'package:go_router/go_router.dart';
import 'package:{{packageName}}/app/features/auth/ui/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:{{packageName}}/core/navigation/app_routes.dart';

class AppRouterConfig {
  static GoRouter goRouter(AuthenticationCubit cubit) => GoRouter(
        routes: AppRoutes.routes,
        redirect: (context, state) {
          final state = cubit.state;
          if (state is UnauthenticatedState) {
            return '/';
          }
          return '/home';
        },
      );
}

''';

const kAppRoutesPath = 'lib/core/navigation/app_routes.dart';
const kAppRoutes = '''
    import 'package:go_router/go_router.dart';
    import 'package:{{packageName}}/app/features/auth/ui/views/screens/sign_in_screen.dart';
    import 'package:{{packageName}}/app/features/home/ui/home_screen.dart';

    class AppRoutes {
      static List<GoRoute> routes = [
        GoRoute(
          path: '/',
          name: 'auth',
          builder: (context, state) => const SignInScreen(),     
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),   
        ),
      ];
    }

''';

const kAnalysisOptionsPath = 'analysis_options.yaml';
const kAnalysisOptions = '''
include: package:very_good_analysis/analysis_options.{{vga_version}}.yaml
linter:
  rules:
    public_member_api_docs: false
''';

/// Feature template
const kFooFeatureImplPath =
    'lib/app/features/{{feature_path_case}}/data/foo_{{feature_path_case}}_impl.dart';
const kFooFeatureImpl = '''
import 'package:{{packageName}}/app/features/{{feature_path_case}}/data/{{feature_path_case}}_interface.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: {{feature}}Interface)
class Foo{{feature}}Impl extends {{feature}}Interface {}
''';
const kFeatureInterfacePath =
    'lib/app/features/{{feature_path_case}}/data/{{feature_path_case}}_interface.dart';
const kFeatureInterface = '''
abstract class {{feature}}Interface {

}
''';
const kFeatureRepositoryPath =
    'lib/app/features/{{feature_path_case}}/data/{{feature_path_case}}_repository.dart';
const kFeatureRepository = '''
import 'package:{{packageName}}/app/features/{{feature_path_case}}/data/{{feature_path_case}}_interface.dart';
import 'package:injectable/injectable.dart';

@singleton
class {{feature}}Repository {
  {{feature}}Repository({required {{feature}}Interface {{feature_param_case}}Interface})
      : _{{feature_param_case}}Interface = {{feature_param_case}}Interface;

  final {{feature}}Interface _{{feature_param_case}}Interface;
}
''';
const kFeatureScreenPath =
    'lib/app/features/{{feature_path_case}}/ui/views/screens/{{feature_path_case}}_screen.dart';
const kFeatureScreen = '''
import 'package:flutter/material.dart';

class {{feature}}Screen extends StatelessWidget {
  const {{feature}}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''';

const kAppRoute = '''
GoRoute(
      path: '/{{route}}',
      name: '{{route}}',
      builder: (context, state) => const {{route_pascal}}Screen(),
    ),
''';

// const kDIContent = '''
//         import 'package:get_it/get_it.dart';
//         import 'package:injectable/injectable.dart';
//         import 'package:{{packageName}}/core/di/di.config.dart';

//         final locator = GetIt.instance;

//         @InjectableInit()
//         Future<void> initDependencies() async => locator.init();
//       ''';

// const kAppRouterConfigContent = '''
//     import 'package:go_router/go_router.dart';
//     import 'package:{{packageName}}/core/navigation/app_routes.dart';

//     class AppRouterConfig {
//        final goRouter = GoRouter(routes: AppRoutes.routes);
//     }

// ''';

// const kAppRoutesContent = '''
//      List<GoRoute> routes = [];
// ''';
