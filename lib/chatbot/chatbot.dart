import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

final model = FirebaseAI.vertexAI().generativeModel(model: 'gemini-2.0-flash');

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await FirestoreService().getUserData();
      setState(() => _userData = data);
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage('Failed to load user data: $e', isUser: false),
        );
      });
    }
  }

  Future<void> _sendPrompt() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || _loading || _userData == null) return;

    setState(() {
      _messages.add(_ChatMessage(prompt, isUser: true));
      _loading = true;
    });

    _controller.clear();

    String fullPrompt;

    final lowerPrompt = prompt.toLowerCase();

    final needsContext = [
      'budget',
      'goal',
      'spending',
      'income',
      'wallet',
      'savings',
      'expense',
      'financial',
    ].any((keyword) => lowerPrompt.contains(keyword));

    if (needsContext) {
      final userContext = await FirestoreService().buildUserContext();
      fullPrompt = '$userContext\nUser: $prompt';
    } else {
      fullPrompt = 'User: $prompt';
    }

    try {
      final content = await model.generateContent([Content.text(fullPrompt)]);
      final reply = content.text ?? 'No response.';
      setState(() {
        _messages.add(_ChatMessage(reply, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage('Error: ${e.toString()}', isUser: false));
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildMessage(_ChatMessage message) {
    final alignment =
        message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = message.isUser ? Colors.deepPurple[300] : Colors.grey[900];
    final textColor = Colors.white;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: MarkdownBody(
          data: message.text,
          styleSheet: MarkdownStyleSheet(p: TextStyle(color: textColor)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendPrompt(),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        borderSide: BorderSide(color: Colors.deepPurple[200]!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendPrompt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage(this.text, {required this.isUser});
}
