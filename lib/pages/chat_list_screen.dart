import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/friend_provider.dart';
import '../providers/opponent_provider.dart';
import '../providers/user_provider.dart';

import 'chat_screen.dart';
import 'login_screen.dart';
import 'setting_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    print('FriendProvider Initializing Called...');
    friendProvider.resetStream();
    friendProvider.addFriend(
        "djkasbgkljsabgdjklbasjkgbdsajkbgsakdjbg", "", context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat List',
          style: TextStyle(
            fontSize: 17,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: Icon(Icons.chat_rounded),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(50, 40),
            ),
            child: Icon(Icons.logout),
            onPressed: () {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              userProvider.clearUser();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          SizedBox(
            width: 5,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(50, 40),
            ),
            child: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          SizedBox(width: 20)
        ],
        backgroundColor: Color.fromARGB(255, 113, 165, 207),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0), // 아래쪽 왼쪽 모서리 둥글게
            bottomRight: Radius.circular(10.0), // 아래쪽 오른쪽 모서리 둥글게
          ),
        ),
      ),
      body: ChatListView(),
    );
  }
}

class ChatListView extends StatefulWidget {
  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
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

  void _friendChat(String opponent) async {
    final opponentProvider =
        Provider.of<OpponentProvider>(context, listen: false);
    opponentProvider.setOpponent(Opponent(
      name: opponent,
    ));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final provider = Provider.of<FriendProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    List<String> chat = [];

    return Container(
      color: Color.fromARGB(255, 215, 237, 255),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: null,
                    minLines: 1,
                    controller: provider.friendController,
                    decoration: InputDecoration(labelText: 'Add Friend'),
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
                    provider.addFriend(user!.user_id, user.name, context);
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
          Expanded(
            child: StreamBuilder<List<Friends>>(
              stream: provider.friendStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final friends = snapshot.data!;
                if (friends.isEmpty) {
                  return Center(child: Text('No Friends'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    int s = 0;
                    if (friend.name == user?.name &&
                        !chat.contains(friend.friend)) {
                      chat.add(friend.friend);
                      s = 1;
                    } else if (friend.friend == user?.name &&
                        friend.lastcontent != "no message" &&
                        !chat.contains(friend.name)) {
                      chat.add(friend.name);
                      s = 1;
                    }
                    return Column(
                      children: [
                        if (friend.name == user?.name && s == 1)
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                minimumSize: Size(screenWidth, 50),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    friend.friend,
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(friend.lastcontent),
                                ],
                              ),
                              onPressed: () => _friendChat(friend.friend),
                            ),
                          ),
                        if (friend.name == user?.name && s == 1)
                          SizedBox(
                            height: 10,
                          ),
                        if (friend.friend == user?.name &&
                            friend.lastcontent != "no message" &&
                            s == 1)
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                minimumSize: Size(screenWidth, 50),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(5.0), // 모서리 둥글게 설정
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    friend.name,
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(friend.lastcontent),
                                ],
                              ),
                              onPressed: () => _friendChat(friend.name),
                            ),
                          ),
                        if (friend.friend == user?.name &&
                            friend.lastcontent != "no message" &&
                            s == 1)
                          SizedBox(
                            height: 10,
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            height: 50,
          )
        ],
      ),
    );
  }
}
