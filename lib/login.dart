import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'secrets.dart';
import 'userTemplate.dart';
import 'main.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String phoneNumber;
  late String otp;

  var username = twilioUsername;
  var password = twilioPassword;
  var authString;
  var bytes;
  var base64string;

  int index = 0;

  late SharedPreferences prefs;

  Future<SharedPreferences> setPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    authString = '$username:$password';
    bytes = utf8.encode(authString);
    base64string = base64Encode(bytes);
  }

  void requestOTP(String phoneNumber) async {
    print("AuthorizatinToken: $base64string");

    Response response = await post(Uri.parse(twilioUri), headers: {
      "Authorization": 'Basic $base64string'
    }, body: {
      "To": phoneNumber,
      "Channel": "whatsapp",
    });

    final data = json.decode(response.body);
    print(data);

    if (data['status'] == "pending") {
      setState(() {
        index = 1;
      });
    }
  }

  void verifyOTP(otp, phoneNumber) async {
    var response = await post(Uri.parse(twilioVerificationCheckUri), headers: {
      "Authorization": 'Basic $base64string'
    }, body: {
      'Code': otp,
      "To": phoneNumber,
    });

    final data = json.decode(response.body);
    print('Status: ${data['status']}');
    if (data['status'] == "approved") {
      setPrefs().then((_prefs) {
        prefs.setBool("SignedIn", true);
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Scaffold(
                    body: UserTemplate(),
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return (Scaffold(
      body: (Center(
        child: IndexedStack(index: index, children: [
          Column(
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
                        print('test');
                        print(phoneNumber);
                      });
                    },
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    requestOTP(phoneNumber);
                  },
                  child: Text('Generate OTP')),

            ],
          ),
          Center(
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
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide()),
                        hintText: 'Enter OTP',
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          otp = value;
                        });
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      verifyOTP(otp, phoneNumber);
                    },
                    child: Text('Verify')),
              ],
            ),
          )
        ]),
      )),
    ));
  }
}
