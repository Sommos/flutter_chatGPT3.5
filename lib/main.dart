import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_key.dart';
import '../model.dart';

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
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  Future<String> generateResponse(String prompt) async {
    const apiKey = apiSecretKey;
    
    var url = Uri.https("api.openai.com" , "/v1/completions");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: json.encode({
        // use gpt-3.5-turbo (higher accuracy mathematics) or text-davinci-003 (more filters)
        "model": "gpt-3.5-turbo",
        "prompt": prompt,
        "temperature": 0,
        "max_tokens": 2000,
        "top_p": 1,
        "frequency_penalty": 0.0,
        "presence_penalty": 0.0,
      }),
    );

    // decode json response
    Map<String, dynamic> newresponse = jsonDecode(response.body);

    return newresponse["choices"][0]["text"];
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
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
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
          onPressed: () async {
            // display user input
            setState(() {
              _messages.add(
                ChatMessage(
                  text: _textController.text, 
                  chatMessageType: ChatMessageType.user
                )
              );
              isLoading = true;
            });

            var input = _textController.text;
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
              .then((_) => _scrollDown());
            
            // call chatbot api
            generateResponse(input).then((value) {
              setState(() {
                isLoading = false;
                // display chatbot response
                _messages.add(ChatMessage(
                  text: value, 
                  chatMessageType: ChatMessageType.bot,
                ));
              });
            });
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
              .then((_) => _scrollDown());
          },
        ),
      ),
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeOut
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final ChatMessageType chatMessageType;
  const ChatMessageWidget({
    super.key,
    required this.text,
    required this.chatMessageType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(16.0),
      color: chatMessageType == ChatMessageType.bot
        ? const Color(0xff444654)
        : const Color(0xff343541),
      child: Row(
        children: [
          chatMessageType == ChatMessageType.bot
            ? Container(
                margin: const EdgeInsets.only(
                  right: 16
                ),
                child: CircleAvatar(
                  backgroundColor: const Color.fromRGBO(
                    16, 163, 127, 1
                  ), 
                  child: Image.asset(
                    "lib/images/open_ai.png",
                    color: Colors.white,
                    scale: 1.5,
                  ),
                ),
              )
            : Container(
                margin: const EdgeInsets.only(right: 16),
                child: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0), 
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0)
                        ),
                      ),
                      child: Text(
                        text, 
                        style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
