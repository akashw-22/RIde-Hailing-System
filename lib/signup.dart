import 'dart:convert';
import 'dart:io';

import 'package:demo_3d/driverSignup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'userTemplate.dart';
import 'riderContract.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  late String name;
  late String phoneNumber;
  late String privateKey;

  // final String rpcUrl = "https://sepolia.infura.io/v3/1c4b1ac4f103486b896dc14e1ba9cf4c";
  // final String hardPrivateKey = '1198d34131de7b91f0596cc431254ec201ca3f9850e44aad644e58ed3a421e74';
  // final EthereumAddress contractAddr = EthereumAddress.fromHex('0xDBE6FCF7304b9ED82532459638AEe1c7bF3d482f');
  
  // final File abiFile = File('./Icon/Profile.png');

  Future<String> submitSignUpDetails (name, phoneNumber, privateKey) async{


    SharedPreferences prefs = await SharedPreferences.getInstance();

    // final File abiFile = File(p.join(p.dirname(Platform.script.path), 'assets/Abi/abi.json'));

    // print("AbiFile: $abiFile");

    // final abiCode = await rootBundle.loadString('assets/Abi/abi.json');

    await signUp(name, phoneNumber);
    print('back');
  
  
    Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserTemplate(),
                  ));
    return "Text";
  }


  @override
  Widget build(BuildContext context) {

    print('building signup');
    // print(dirname(Platform.script.path));
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          offset: Offset(0, 20),
                          blurRadius: 20)
                    ]),
                child: Column(
                  children: [Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide()),
                        hintText: 'Enter Name',
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          name = value;
                          print(name);
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide()),
                        hintText: 'Enter Phone Number',
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          phoneNumber = value;
                          print(phoneNumber);
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide()),
                        hintText: 'Enter Private Key',
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          privateKey = value;
                          print(privateKey);
                        });
                      },
                    ),
                  )
                  ]
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  print(submitSignUpDetails(name, phoneNumber, privateKey));
                },
                child: Text('SignUp')),
            TextButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: 
                (context) => Scaffold(body: DriverSignUp())));
            }, 
            child: Text('SignUp as Driver'))
          ],
        ),
      ),
    );
  }
}
