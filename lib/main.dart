import 'package:chat_bot/core/DI/service_locator.dart';
import 'package:chat_bot/core/service/firebase_auth_service.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_bloc.dart';
import 'package:chat_bot/features/chat_bot/presentation/view/bot_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await init();

  final authService = getIt<FirebaseAuthService>();
  final userId = await authService.signInAnonymously();

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => getIt<BotBloc>(param1: userId))],
      child: MyApp(userId: userId),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: BotScreen(userId: userId));
  }
}
