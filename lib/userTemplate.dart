import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'home.dart';
import 'maps.dart';
import 'profile.dart';
import 'login.dart';

class UserTemplate extends StatefulWidget{

  UserTemplate({super.key});

  @override
  State<UserTemplate> createState() => _UserTemplateState();
}

class _UserTemplateState extends State<UserTemplate> {

  Widget Default = const Card(child: Text("Default Page"));
  final PageController _pageController = PageController(
      initialPage: 2,
      keepPage: true,
    );
    int _selectedItemPosition = 2;

    void logOut() {
      Navigator.push(context, MaterialPageRoute(
              builder: (context) => Login(),
                  ));
    }

  @override
  Widget build(BuildContext context){
    return Scaffold(
            extendBody: true,
            backgroundColor: Colors.grey[300],
            body: SafeArea(
              child: Center(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  pageSnapping: true,
                  onPageChanged: (value) => {},
                  children: [Default, Default, BigCard(), MapsPage(), Profile()],
                ),
              ),
            ),
            bottomNavigationBar: SnakeNavigationBar.color(
              behaviour: SnakeBarBehaviour.floating,
              snakeShape: SnakeShape.circle,
              padding: const EdgeInsets.all(20),
              elevation: 7,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              // /configuration for SnakeNavigationBar.color
              snakeViewColor: Colors.black,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.blueGrey,
              showUnselectedLabels: false,
              showSelectedLabels: true,
              currentIndex: _selectedItemPosition,
              onTap: (index) => setState(() {

                if(index == 0){
                  logOut();
                }
                _pageController.jumpToPage(index);
                _selectedItemPosition = index;
              }),
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.logout), label: 'LogOut'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.history), label: 'History'),
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.location_on), label: 'map'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'profile'),
              ],
              selectedLabelStyle: const TextStyle(fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
            ),
          );
  }
}