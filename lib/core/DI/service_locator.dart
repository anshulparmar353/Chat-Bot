import 'package:chat_bot/core/client/dio_client.dart';
import 'package:chat_bot/features/chat_bot/data/datasource/chatbot_api.dart';
import 'package:chat_bot/features/chat_bot/data/repo_impl/chatbot_repo_impl.dart';
import 'package:chat_bot/features/chat_bot/domain/usecases/chatbot_usecases.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  
  getIt.registerSingleton(DioClient().dio);

  getIt.registerSingleton(ChatbotApi(getIt<Dio>()));

  getIt.registerSingleton(ChatbotRepoImpl(api: getIt<ChatbotApi>()));

  getIt.registerSingleton(SendMessageUseCase(repo: getIt<ChatbotRepoImpl>()));

  getIt.registerSingleton(BotBloc(getIt<SendMessageUseCase>()));
}
