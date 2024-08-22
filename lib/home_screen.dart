import 'package:flutter/material.dart';
import 'package:gemini_ai/message_widget.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'AIzaSyBnzTwAfZDlgWjbMZuTr_XLgiy8Kyo-2j0', // Use the API key from the environment variable
    );
    _chatSession = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build With Gemini'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _chatSession.history.length,
              itemBuilder: (context, index) {
                final Content content = _chatSession.history.toList()[index];
                final text = content.parts.whereType<TextPart>().map<String>((e) => e.text).join('');
                return MessageWidget(text: text, isFromUser: content.role == 'user');
              },
            ),
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: textFieldDecoration(),
                    controller: _textController,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).colorScheme.secondary),
                  onPressed: () => _sendChatMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration textFieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Enter a Prompt...',
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });
    try {
      final response = await _chatSession.sendMessage(Content.text(message));
      final text = response.text;
      if (text == null) {
        _showError('No Response from API');
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      );
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went Wrong!'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
