import 'package:flutter/material.dart';
import 'userTemplate.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.

        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SharedPreferences prefs;
  bool signedIn = false;
  bool isLoading = true;
  bool isRider = true;

  Future<SharedPreferences> setPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = false;
    });
    return prefs;
  }

  @override
  void initState() {
    print('Inside initState');
    setPrefs().then((prefs){

      print(prefs.getKeys());
      if(prefs.containsKey('privateKey')){
        if(prefs.containsKey('Rider')){
          if(prefs.getBool('Rider') == true){
            isRider = true;
          }
          else{
            isRider = false;
          }
        }
        signedIn = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    PageController _pageController = PageController(
      initialPage: 2,
      keepPage: true,
    );
    print('building _myHomePageState');
    // return SignUp();
    // return UserTemplate();

    Widget page;
    print('isLoading: $isLoading');
    if(isLoading){
      return Center(
            child: CircularProgressIndicator(),
      );
    }
    else{
    if(signedIn){
      if(isRider){
        page = UserTemplate();}
      else{
        page = Center(child: Text('DriverHomePage'));}
    }
    else{
      page = SignUp();
    }
    }
    return Stack(children: [page, 
    // SafeArea(
    //   child: ElevatedButton(child: Text('Clear Keys'), onPressed: () { prefs.clear(); 
    //       Navigator.push(context, MaterialPageRoute(builder: (context) {return MyApp();}));
    //       }),
    // )
    ]
    );
  }
}
