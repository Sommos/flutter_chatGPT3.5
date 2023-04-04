import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late bool isLoading;
  final TextEditingController _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> message = [];

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Flutter ChatGPT 3.5",
              maxLines: 2,
              textAlign: TextAlign.start,
            ),
          ),
          // background color for the chatbot
          backgroundColor: const Color(0xff444654),
        ),
        // background color for appbar
        backgroundColor: const Color(0xff343541),
        body: Column(
          children: [
            // chat body
             Expanded(
              child: _buildList(),
            ),
            Visibility(
              visible: isLoading, 
              child: const Padding(
                padding: EdgeInsets.all(8.0), 
                child: CircularProgressIndicator(
                  color: Colors.white
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // input text field
                  _buildInput(),
                  // submit button
                  _buildSubmit(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      itemCount: _messages.length,
      controller: _scrollController,
      itemBuilder: ((context, index) {
        return ChatMessageWidget();
      }),
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        decoration: const InputDecoration(
          fillColor:Color(0xff444654),
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      )
    );
  }

  Widget _buildSubmit() {
    return Visibility(
      visible: !isLoading,
      child: Container(
        color: const Color(0xff444654),
        child: IconButton(
          icon: const Icon(
            Icons.send_rounded,
            color: Color(0xff343541),
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}