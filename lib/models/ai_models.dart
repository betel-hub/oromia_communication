class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;
  final List<AiHit> hits;
  final List<AiService> services;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.isError = false,
    DateTime? timestamp,
    this.hits = const [],
    this.services = const [],
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiHit {
  final String type;
  final String title;
  final String? snippet;
  final String? url;

  AiHit({
    this.type = 'page',
    required this.title,
    this.snippet,
    this.url,
  });

  factory AiHit.fromJson(Map<String, dynamic> json) {
    return AiHit(
      type: json['type']?.toString() ?? 'page',
      title: json['title']?.toString() ?? '',
      snippet: json['snippet']?.toString(),
      url: json['url']?.toString(),
    );
  }

  String get icon {
    switch (type) {
      case 'news':
        return '📰';
      case 'service':
        return '💳';
      case 'page':
        return '📄';
      case 'sector':
        return '🏛️';
      case 'tender':
        return '📋';
      default:
        return '🔗';
    }
  }
}

class AiService {
  final String code;
  final String name;
  final String? description;
  final String? url;

  AiService({
    required this.code,
    required this.name,
    this.description,
    this.url,
  });

  factory AiService.fromJson(Map<String, dynamic> json) {
    return AiService(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      url: json['url']?.toString(),
    );
  }
}

class AiFaq {
  final String question;

  AiFaq({required this.question});

  factory AiFaq.fromJson(dynamic json) {
    if (json is String) return AiFaq(question: json);
    if (json is Map) {
      return AiFaq(
        question: (json['question'] ?? json['q'] ?? json['text'] ?? '')
            .toString(),
      );
    }
    return AiFaq(question: '');
  }
}

class AiChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? error;

  AiChatState({
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}