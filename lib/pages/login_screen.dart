import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart' as app_provider;

import '../providers/user_provider.dart' as user_provider;

import 'chat_list_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController IdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _showPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  void _signIn(BuildContext context) async {
    final response = await supabase
        .from('users')
        .select()
        .eq('user_id', IdController.text)
        .execute();
    if (response.error == null &&
        response.data != null &&
        !response.data.isEmpty) {
      if (response.data[0]['user_pw'] == passwordController.text) {
        final userProvider =
            app_provider.Provider.of<user_provider.UserProvider>(context,
                listen: false);
        userProvider.setUser(user_provider.User(
          user_id: response.data[0]['user_id'],
          user_pw: response.data[0]['user_pw'],
          name: response.data[0]['name'],
          phone: response.data[0]['phone'],
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatListScreen()),
        );
      } else {
        _showPopup(context, '잘못된 사용자 정보입니다.');
      }
    } else {
      _showPopup(context, '잘못된 사용자 정보입니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 215, 237, 255),
      appBar: AppBar(
        title: Text(
          '로그인',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 113, 165, 207),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0), // 아래쪽 왼쪽 모서리 둥글게
            bottomRight: Radius.circular(10.0), // 아래쪽 오른쪽 모서리 둥글게
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, // 그림자 색상
                    blurRadius: 10.0, // 흐림 반경
                    spreadRadius: 2.0, // 확산 반경
                    offset: Offset(5.0, 5.0), // 그림자 오프셋 (x, y)
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Text(
                      "Chat",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 119, 139, 228),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextField(
                      controller: IdController,
                      decoration: InputDecoration(labelText: '아이디'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: '비밀번호'),
                      obscureText: true,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10.0), // 모서리 둥글게 설정
                            ),
                          ),
                          onPressed: () => _signIn(context),
                          child: Text('로그인'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10.0), // 모서리 둥글게 설정
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()),
                            );
                          },
                          child: Text('회원 가입'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
