import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

class ChatProvider with ChangeNotifier {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  final TextEditingController messageController = TextEditingController();
  final List<Message> _messages = [];
  Stream<List<Message>>? messagesStream;

  ChatProvider() {
    init();
  }

  void init() {
    if (messagesStream != null) return;
    print('Initializing ChatProvider...');

    messagesStream = supabaseClient
        .from('messages')
        .stream(['id'])
        .order('created_at')
        .execute()
        .map((data) {
          final filteredData = data.where((e) => e['name'] != "").toList();
          final messages = filteredData.map((e) => Message.fromMap(e)).toList();
          _messages.clear();
          _messages.addAll(messages);
          notifyListeners();
          print('Messages updated');
          return _messages;
        })
        .asBroadcastStream();
    print('Initialized ChatProvider Finish');
  }

  void resetStream() {
    init();
  }

  void sendMessage(String name, String recipient) async {
    final location = tz.getLocation('Asia/Seoul');
    final koreaTime = tz.TZDateTime.now(location);
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(koreaTime);

    final message = messageController.text;
    final response = await supabaseClient.from('messages').insert([
      {
        'content': message,
        'name': name,
        'Recipient': recipient,
        'created_at': formattedTime
      }
    ]).execute();
    final change1 = await supabaseClient
        .from('friends')
        .update({'lastcontent': message})
        .eq('user_name', name)
        .eq('friend_name', recipient)
        .execute();
    final change2 = await supabaseClient
        .from('friends')
        .update({'lastcontent': message})
        .eq('user_name', recipient)
        .eq('friend_name', name)
        .execute();
    if (response.error != null) {
      print('Error sending message: ${response.error!.message}');
    } else {
      print('message send success!');
      if (name == "") {
        final response2 = await supabaseClient
            .from('messages')
            .delete()
            .eq('created_at', formattedTime)
            .execute();
        if (response2.error != null) {
          print('Error deleting message: ${response2.error!.message}');
        } else {
          print('Message deleted successfully!');
          notifyListeners();
        }
      }
      if (change1.error != null) {
        print('Error changing last name: ${change1.error!.message}');
      } else if (change2.error != null) {
        print('Error changing last recipient: ${change2.error!.message}');
      }
      messageController.clear();
      notifyListeners();
    }
  }

  List<Message> get messages => _messages;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}

class Message {
  final int id;
  final String content;
  final DateTime createdAt;
  final String name;
  final String recipient;

  Message({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.name,
    required this.recipient,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      name: map['name'],
      recipient: map['Recipient'],
    );
  }
}
