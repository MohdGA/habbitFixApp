import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'ai_repository.g.dart';

// ─── Chat message model ───────────────────────────────────────────────────────

enum MessageRole { user, assistant }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
  });

  ChatMessage copyWith({String? content, bool? isStreaming}) => ChatMessage(
    id: id,
    role: role,
    content: content ?? this.content,
    timestamp: timestamp,
    isStreaming: isStreaming ?? this.isStreaming,
  );
}

// ─── Repository ───────────────────────────────────────────────────────────────

class AiRepository {
  final Dio _dio;
  AiRepository(this._dio);

  Future<String> chat(String message) async {
    final response = await _dio.post(
      '/ai/chat',
      data: {'message': message},
      options: Options(receiveTimeout: const Duration(seconds: 60)),
    );
    return (response.data as Map<String, dynamic>)['message'] as String? ?? '';
  }

  Future<List<String>> getSuggestions() async {
    try {
      final response = await _dio.get('/ai/suggestions');
      final list = response.data['suggestions'] as List<dynamic>;
      return list.cast<String>();
    } catch (_) {
      return ['How am I doing?', "I'm having a craving", 'Analyze my week', 'Motivate me!'];
    }
  }

  Future<String> getWeeklySummary() async {
    final response = await _dio.get('/ai/weekly-summary');
    return response.data['summary'] as String;
  }

  Future<void> clearHistory() async {
    await _dio.delete('/ai/history');
  }
}

@riverpod
AiRepository aiRepository(AiRepositoryRef ref) {
  return AiRepository(ref.watch(dioProvider));
}

@riverpod
Future<List<String>> aiSuggestions(AiSuggestionsRef ref) {
  return ref.watch(aiRepositoryProvider).getSuggestions();
}
