import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_models.dart';
import '../repositories/ai_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository();
});

final aiFaqProvider = FutureProvider<List<AiFaq>>((ref) async {
  return ref.watch(aiRepositoryProvider).getFaq();
});

final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  return AiChatNotifier(ref);
});

class AiChatNotifier extends StateNotifier<AiChatState> {
  final Ref _ref;

  AiChatNotifier(this._ref) : super(AiChatState());

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      clearError: true,
    );

    final reply = await _ref.read(aiRepositoryProvider).sendMessage(trimmed);

    state = state.copyWith(
      messages: [...state.messages, reply],
      isSending: false,
    );
  }

  void clear() => state = AiChatState();
}