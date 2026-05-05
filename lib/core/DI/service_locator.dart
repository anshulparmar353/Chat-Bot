import 'package:chat_bot/core/client/dio_client.dart';
import 'package:chat_bot/core/service/firebase_auth_service.dart';
import 'package:chat_bot/features/chat_bot/data/datasource/chat_remote_datasource_impl.dart';
import 'package:chat_bot/features/chat_bot/data/datasource/chatbot_api.dart';
import 'package:chat_bot/features/chat_bot/data/datasource/chat_remote_datasource.dart';
import 'package:chat_bot/features/chat_bot/data/repo_impl/chat_repository_impl.dart';
import 'package:chat_bot/features/chat_bot/data/repo_impl/chatbot_repo_impl.dart';
import 'package:chat_bot/features/chat_bot/domain/repository/chat_repository.dart';
import 'package:chat_bot/features/chat_bot/domain/repository/chatbot_repo.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerLazySingleton<Dio>(() => DioClient().dio);

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  getIt.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(getIt<FirebaseAuth>()),
  );

  getIt.registerLazySingleton<ChatbotApi>(() => ChatbotApi(getIt<Dio>()));

  getIt.registerLazySingleton<ChatRemoteDatasource>(
    () => ChatRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(getIt<ChatRemoteDatasource>()),
  );

  getIt.registerLazySingleton<ChatbotRepo>(
    () => ChatbotRepoImpl(api: getIt<ChatbotApi>()),
  );

  getIt.registerFactoryParam<BotBloc, String, void>(
    (userId, _) => BotBloc(
      chatRepository: getIt<ChatRepository>(),
      chatbotRepo: getIt<ChatbotRepo>(),
      userId: userId,
    ),
  );
}
