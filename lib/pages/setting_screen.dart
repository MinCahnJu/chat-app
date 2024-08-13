import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:provider/provider.dart' as app_provider;

import '../providers/user_provider.dart' as user_provider;

import 'chat_list_screen.dart';

class SettingsScreen extends StatelessWidget {
  final supabase.SupabaseClient supabaseClient =
      supabase.Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user =
        app_provider.Provider.of<user_provider.UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
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
        backgroundColor: Color.fromARGB(255, 113, 165, 207),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0), // 아래쪽 왼쪽 모서리 둥글게
            bottomRight: Radius.circular(10.0), // 아래쪽 오른쪽 모서리 둥글게
          ),
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 215, 237, 255),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 100, child: Center(child: Text("사용자"))),
                        SizedBox(
                            width: 100,
                            child: Center(child: Text("${user?.name}")))
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        SizedBox(width: 100, child: Center(child: Text("아이디"))),
                        SizedBox(
                            width: 100,
                            child: Center(child: Text('${user?.user_id}')))
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        SizedBox(
                            width: 100, child: Center(child: Text("전화번호"))),
                        SizedBox(
                            width: 100,
                            child: Center(child: Text('${user?.phone}')))
                      ],
                    ),
                  ],
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
