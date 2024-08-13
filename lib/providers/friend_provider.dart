import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

class FriendProvider with ChangeNotifier {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  final TextEditingController friendController = TextEditingController();
  final List<Friends> _friends = [];
  Stream<List<Friends>>? friendStream;

  FriendProvider() {
    init();
  }

  void init() {
    if (friendStream != null) return;
    print('Initializing FriendProvider...');

    friendStream = supabaseClient
        .from('friends')
        .stream(['id'])
        .order('created_at')
        .execute()
        .map((data) {
          final filteredData = data
              .where((e) => e['user_name'] != "" || e['friend_name'] != "")
              .toList();
          final friends = filteredData.map((e) => Friends.fromMap(e)).toList();
          _friends.clear();
          _friends.addAll(friends);
          notifyListeners();
          print('Friends updated');
          return _friends;
        })
        .asBroadcastStream();
    print('Initialized FriendProvider Finish');
  }

  void resetStream() {
    init();
  }

  void addFriend(String userid, String name, BuildContext context) async {
    final location = tz.getLocation('Asia/Seoul');
    final koreaTime = tz.TZDateTime.now(location);
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(koreaTime);

    final friendid = friendController.text;
    int count = 1;
    final response;

    final friendInfo = await supabaseClient
        .from('users')
        .select()
        .eq('user_id', friendid)
        .single()
        .execute();

    if (friendInfo.data == [] || friendInfo.data == null) {
      response = await supabaseClient.from('friends').insert([
        {
          'user_id': userid,
          'user_name': name,
          'friend_id': friendid,
          'friend_name': "",
          'lastcontent': "no message",
          'created_at': formattedTime
        }
      ]).execute();
    } else {
      response = await supabaseClient.from('friends').insert([
        {
          'user_id': userid,
          'user_name': name,
          'friend_id': friendid,
          'friend_name': friendInfo.data['name'],
          'lastcontent': "no message",
          'created_at': formattedTime
        }
      ]).execute();
    }

    if ((friendid == "" || friendInfo.data == [] || friendInfo.data == null) &&
        userid != "djkasbgkljsabgdjklbasjkgbdsajkbgsakdjbg") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록되지 않은 아이디 입니다.')),
      );
      count = 0;
    }

    if (response.error != null) {
      print('Error adding friend: ${response.error!.message}');
    } else {
      print('friend add success!');
      if (userid == "djkasbgkljsabgdjklbasjkgbdsajkbgsakdjbg" ||
          friendInfo.data == [] ||
          friendInfo.data == null ||
          friendid == "" ||
          count == 0) {
        final response2 = await supabaseClient
            .from('friends')
            .delete()
            .eq('created_at', formattedTime)
            .execute();
        if (response2.error != null) {
          print('Error deleting Friend: ${response2.error!.message}');
        } else {
          print('Friend deleted successfully!');
          notifyListeners();
        }
      }
      friendController.clear();
      notifyListeners();
    }
  }

  List<Friends> get friends => _friends;

  @override
  void dispose() {
    friendController.dispose();
    super.dispose();
  }
}

class Friends {
  final int id;
  final String name;
  final String friend;
  final String lastcontent;

  Friends({
    required this.id,
    required this.name,
    required this.friend,
    required this.lastcontent,
  });

  factory Friends.fromMap(Map<String, dynamic> map) {
    return Friends(
      id: map['id'],
      name: map['user_name'],
      friend: map['friend_name'],
      lastcontent: map['lastcontent'],
    );
  }
}
