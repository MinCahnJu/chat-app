import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController IdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();

  bool containsAlphabet(String input) {
    RegExp regex = RegExp(r'[a-zA-Z]');
    return regex.hasMatch(input);
  }

  bool containsNumber(String input) {
    RegExp regex = RegExp(r'[0-9]');
    return regex.hasMatch(input);
  }

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

  void _signUp(BuildContext context) async {
    if (nameController.text == "" || phoneController.text == "" || IdController.text == "" || passwordController.text == "" || password2Controller.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('빈칸을 입력해주세요.')),
      );
    } else if (passwordController.text != password2Controller.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호가 서로 다릅니다.\n비밀번호는 8자 이상이어야 하고,\n영문자, 숫자가 필수입니다.')),
      );
    } else if (passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호는 8자 이상이어야 합니다.\n\n비밀번호는 8자 이상이어야 하고,\n영문자, 숫자가 필수입니다.')),
      );
    } else if (!containsAlphabet(passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호는 영문자를 포함해야 합니다.\n\n비밀번호는 8자 이상이어야 하고,\n영문자, 숫자가 필수입니다.')),
      );
    } else if (!containsNumber(passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호는 숫자를 포함해야 합니다.\n\n비밀번호는 8자 이상이어야 하고,\n영문자, 숫자가 필수입니다.')),
      );
    } else {
      try {
        final response = await supabase.from('users').insert({
          'user_id': IdController.text,
          'user_pw': passwordController.text,
          'name': nameController.text,
          'phone': phoneController.text,
        }).execute();

        if (response.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원 가입에 성공했습니다!\n로그인 해주세요.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          _showPopup(context, '회원 가입에 실패했습니다.\n\n중복된 아이디!');
        }
      } catch (e) {
        _showPopup(context, '회원 가입에 실패했습니다.\n\n서버 오류: ' + e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "회원 가입",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left_rounded,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
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
        child: Padding(
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
                  padding: const EdgeInsets.all(25.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          "정보 입력",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 119, 139, 228),
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: '이름'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(labelText: '전화번호'),
                        ),
                        SizedBox(
                          height: 10,
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
                          height: 10,
                        ),
                        TextField(
                          controller: password2Controller,
                          decoration: InputDecoration(labelText: '비밀번호 확인'),
                          obscureText: true,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0), // 모서리 둥글게 설정
                            ),
                          ),
                          onPressed: () => _signUp(context),
                          child: Text('회원가입'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
