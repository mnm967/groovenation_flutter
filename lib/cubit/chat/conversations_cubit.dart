import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/cubit/state/chat_state.dart';
import 'package:groovenation_flutter/data/repo/chat_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ConversationsCubit extends Cubit<ChatState> {
  final ChatRepository chatRepository;

  ConversationsCubit(this.chatRepository) : super(ConversationsInitialState());

  void getConversationPersons() async {
    emit(ConversationPersonsLoadingState());

    try {
      var result = await chatRepository.getConversationPersons();
      emit(ConversationPersonsLoadedState(persons: result));
    } catch (e) {
      emit(ConversationPersonsErrorState(AppError.NETWORK_ERROR));
    }
  }
}
