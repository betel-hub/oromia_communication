import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/ai_models.dart';

class AiRepository {
  final ApiClient _client = ApiClient();

  Future<List<AiFaq>> getFaq() async {
    try {
      final response = await _client.dio.get('ai/faq');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => AiFaq.fromJson(e)).toList();
        }
        if (data is Map && data['items'] is List) {
          return (data['items'] as List)
              .map((e) => AiFaq.fromJson(e))
              .toList();
        }
      }
      return _defaultFaqs();
    } catch (e) {
      debugPrint('FAQ error: $e');
      return _defaultFaqs();
    }
  }

  List<AiFaq> _defaultFaqs() {
    return [
      AiFaq(question: 'What bureau services can I pay for?'),
      AiFaq(question: 'How do I contact the Bureau?'),
      AiFaq(question: 'What is Kallacha Oromia?'),
      AiFaq(question: 'How do I check tenders?'),
    ];
  }

  Future<ChatMessage> sendMessage(String message) async {
    try {
      final response = await _client.dio.post(
        'ai/chat',
        data: {'message': message},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] ?? {};

        final hits = (data['hits'] as List? ?? [])
            .map((h) => AiHit.fromJson(Map<String, dynamic>.from(h)))
            .toList();

        final services = (data['services'] as List? ?? [])
            .map((s) => AiService.fromJson(Map<String, dynamic>.from(s)))
            .toList();

        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: data['answer']?.toString() ?? 'No response',
          isUser: false,
          hits: hits,
          services: services,
        );
      }

      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response.data['message']?.toString() ??
            'Could not understand that.',
        isUser: false,
        isError: true,
      );
    } on DioException catch (e) {
      debugPrint('AI DioException: ${e.message}');
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: e.type == DioExceptionType.connectionTimeout
            ? 'Request timed out. Please try again.'
            : 'Connection error. Check your internet and try again.',
        isUser: false,
        isError: true,
      );
    } catch (e) {
      debugPrint('AI error: $e');
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Something went wrong. Please try again.',
        isUser: false,
        isError: true,
      );
    }
  }
}