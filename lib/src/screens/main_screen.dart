import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/data_keys.dart';
import '../states/user_controller.dart';
import '../widgets/expandable_fab.dart';
import 'chat/chat_list_page.dart';
import 'home/items_screen.dart';
import 'near/google_map_screen.dart';
import 'near/map_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _bottomSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    debugPrint("************************* >>> build from MainScreen");
    return Scaffold(
      floatingActionButton: FloatingActionButton( /// 글쓰기 버튼
            onPressed: () {
              Get.toNamed('/$ROUTE_INPUT');
            },
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.edit),

          /*MaterialButton(
            onPressed: () {},
            shape: const CircleBorder(),
            height: 48,
            color: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.input),
          ),*/
          // MaterialButton(
        //           //   onPressed: () {},
        //           //   shape: const CircleBorder(),
        //           //   height: 48,
        //           //   color: Theme.of(context).colorScheme.primary,
        //           //   child: const Icon(Icons.add),
        //           // ),

      ),
      appBar: AppBar(
        // centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("배달을 반하다",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text("ID:  " + UserController.to.userModel.value!.phoneNumber,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),

                ],
        ),

        actions: [
          IconButton(
            onPressed: () {
              // 로그아웃하면 '/auth' 로 이동
              // UserController.to.setUserAuth(false);
              // user 상태가 변하면서 스트림이 자동 호출되면서 로그아웃됨
              FirebaseAuth.instance.signOut();
              //** beamer 에서는 이 부분을 추가해야 로그아웃이 정상적으로 된다
              // context.beamToNamed('/');
            },
            icon: const Icon(Icons.logout),
          ),
          /*IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.search),
          ),*/
          /*IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.text_justify),
          ),*/
        ],
      ),
      body: IndexedStack(
        index: _bottomSelectedIndex,
        children: <Widget>[
          const ItemsScreen(), // items_page
          (UserController.to.userModel.value == null)
              ? Container()
              : MapScreen(UserController.to.userModel.value!), // 글목록
          // (UserController.to.userModel.value == null)
          //     ? Container()
          //     : GoogleMapScreen(UserController.to.userModel.value!), // 내위치
          (UserController.to.userModel.value == null)
              ? Container()
              : ChatListPage(
                  userKey: UserController.to.userModel.value!.userKey),
          Container(color: Colors.accents[3]),
          Container(color: Colors.accents[5]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        // 아이콘이 선택되지 않아도 label 이 보이게 하는 옵션
        // shifting 으로 설정하면 클릭시에만 label 이 보임,
        type: BottomNavigationBarType.fixed,
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
        // selectedItemColor: Colors.black,
        // unselectedItemColor: Colors.black.withOpacity(.60),
        // 아이콘이 클릭되면 onTap 이 실행되고, 이걸 currentIndex 에 전달해야 함
        onTap: (index) {
          setState(() {
            debugPrint('BottomNavigationBar(index): $index');
            _bottomSelectedIndex = index;
          });
        },
        // 클릭된 화면으로 이동하려면 매핑해야함
        currentIndex: _bottomSelectedIndex,
        // free icons : flaticon.com 에서 다운로드
        items: [
          // 아이콘이 클릭되면 onTap 이 실행됨,
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon:  Icon(Icons.room),
            label: '내 근처',
          ),

          BottomNavigationBarItem(
            icon:  Icon(Icons.wechat_outlined),
            label: '채팅',
          ),
        ],
      ),
    );
  }
}
