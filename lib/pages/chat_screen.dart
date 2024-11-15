import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../providers/opponent_provider.dart';
import '../providers/user_provider.dart';

import 'chat_list_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    print('ChatProvider Initializing Called...');
    chatProvider.resetStream();
    chatProvider.sendMessage("", "");
  }

  @override
  Widget build(BuildContext context) {
    final opponent = Provider.of<OpponentProvider>(context).opponent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${opponent?.name}',
          style: TextStyle(
            fontSize: 17,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(50, 40),
            backgroundColor: Color.fromARGB(255, 113, 165, 207),
            iconColor: Colors.white,
            elevation: 0,
          ),
          child: Icon(
            Icons.keyboard_arrow_left_rounded,
            size: 30,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ChatListScreen()),
            );
          },
        ),
        leadingWidth: 30,
        backgroundColor: Color.fromARGB(255, 113, 165, 207),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0), // 아래쪽 왼쪽 모서리 둥글게
            bottomRight: Radius.circular(10.0), // 아래쪽 오른쪽 모서리 둥글게
          ),
        ),
      ),
      body: ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          _isUserScrolling = false;
        } else {
          _isUserScrolling = false;
        }
      } else {
        _isUserScrolling = true;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final user = Provider.of<UserProvider>(context).user;
    final opponent = Provider.of<OpponentProvider>(context).opponent;

    return Container(
      color: Color.fromARGB(255, 215, 237, 255),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: provider.messagesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return Center(child: Text('No messages'));
                }
                String last = "";
                String current = "";
                int max = messages.length;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    if (last == "" &&
                        ((message.name == user?.name &&
                                message.recipient == opponent?.name) ||
                            (message.name == opponent?.name &&
                                message.recipient == user?.name))) {
                      last = message.createdAt.toString().substring(0, 10);
                      current = message.createdAt.toString().substring(0, 10);
                    } else if ((message.name == user?.name &&
                            message.recipient == opponent?.name) ||
                        (message.name == opponent?.name &&
                            message.recipient == user?.name)) {
                      last = current;
                      current = message.createdAt.toString().substring(0, 10);
                    }
                    return Column(
                      children: [
                        if (index == max - 1)
                          SizedBox(
                            child: Text(
                              current,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ),
                        if (index == max - 1)
                          SizedBox(
                            height: 10,
                          ),
                        if (message.name == user?.name &&
                            message.recipient == opponent?.name)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    child: Text(
                                      message.name,
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  SizedBox(
                                    child: Text(
                                      message.createdAt
                                          .toString()
                                          .substring(11, 19),
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5),
                              IntrinsicWidth(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: screenWidth * 0.6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 223, 214, 140),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(message.content),
                                  ),
                                ),
                              ),
                              Container(width: 15),
                            ],
                          ),
                        if (message.name == user?.name &&
                            message.recipient == opponent?.name)
                          SizedBox(
                            height: 10,
                          ),
                        if (message.name == opponent?.name &&
                            message.recipient == user?.name)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 15),
                              IntrinsicWidth(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: screenWidth * 0.6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 173, 173, 171),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(message.content),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Column(
                                children: [
                                  SizedBox(
                                    child: Text(
                                      message.name,
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  SizedBox(
                                    child: Text(
                                      message.createdAt
                                          .toString()
                                          .substring(11, 19),
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        if (message.name == opponent?.name &&
                            message.recipient == user?.name)
                          SizedBox(
                            height: 10,
                          ),
                        if (last != current)
                          SizedBox(
                            child: Text(
                              last,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: Color.fromARGB(255, 255, 255, 255),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      minLines: 1,
                      controller: provider.messageController,
                      decoration: InputDecoration(labelText: 'Enter message'),
                      onChanged: (text) {
                        if (!_isUserScrolling) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_scrollController.hasClients) {
                              _scrollController.jumpTo(0);
                            }
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      provider.sendMessage(user!.name, opponent!.name);
                      Future.delayed(Duration(milliseconds: 100), () {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(0);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
