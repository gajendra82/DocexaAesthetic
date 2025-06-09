import 'package:docexaaesthetic/Repository/PatientRepository';
import 'package:docexaaesthetic/blocs/AuthBloc.dart';
import 'package:docexaaesthetic/blocs/PatientBloc.dart';
import 'package:docexaaesthetic/blocs/PatientEvent.dart';
import 'package:docexaaesthetic/screens/CreateAccountPage.dart';
import 'package:docexaaesthetic/screens/LoginPage.dart';
import 'package:docexaaesthetic/screens/SplashScreen.dart';
import 'package:docexaaesthetic/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/image_bloc.dart';
import 'screens/image_upload_screen.dart';

// Add this to log bloc state changes
class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

void main() {
  // Enable bloc logging in debug mode
  Bloc.observer = SimpleBlocObserver();

  // Initialize services and repositories
  final apiService = ApiService();
  final patientRepository = PatientRepository(apiService);

  // Set default date format and user info
  const defaultDateFormat = 'YYYY-MM-DD HH:MM:SS';
  const currentUser = 'gajendra82';
  const currentDateTime = '2025-05-27 11:32:50';

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>(
          create: (context) => apiService,
        ),
        RepositoryProvider<PatientRepository>(
          create: (context) => patientRepository,
        ),
      ],
      child: MyApp(patientRepository: patientRepository),
    ),
  );
}

class MyApp extends StatelessWidget {
  final PatientRepository patientRepository;

  const MyApp({Key? key, required this.patientRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ImageBloc>(
          create: (context) => ImageBloc(patientRepository),
        ),
        BlocProvider<PatientBloc>(
          create: (context) => PatientBloc(
            patientRepository: patientRepository,
          )..add(const FetchPatientsEvent()),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(patientRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Docexa Aesthetic',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => LoginPage(
                onCreateAccountTap: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),
          '/register': (context) => const CreateAccountPage(),
          '/image-upload': (context) => const ImageUploadScreen(),
        },
      ),
    );
  }
}
