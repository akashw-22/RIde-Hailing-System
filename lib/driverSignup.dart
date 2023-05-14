import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'userTemplate.dart';
import 'signup.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ipfs_client_flutter/ipfs_client_flutter.dart';

class DriverSignUp extends StatefulWidget {
  DriverSignUp({super.key});

  @override
  State<DriverSignUp> createState() => _DriverSignUpState();
}

class _DriverSignUpState extends State<DriverSignUp> {
  late String name;
  late String phoneNumber;
  late String privateKey;
  late String? licensePath;
  late String rcPath;
  final picker = ImagePicker();
  String rcText = "Upload Rc Book";
  String licenseText = "Upload License";
  late IpfsClient ipfsClient;
  var tokenDecoded = '2PF01MvfHcJ8Nis33i3eENQ7PDO:c1574cb91ebeee495fb2b4429affe0c4';
  var url = 'https://ipfs.infura.io:5001';
  var add = '/api/v0/add';
  

  Future<String> submitSignUpDetails(
      name, phoneNumber, privateKey, licensePath, rcPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('inside submitSignUp');
    var encoded = base64Encode(utf8.encode(tokenDecoded));
    //Response resp = await post(Uri.parse(url + add), headers:{"Authorization": 'Basic $encoded'},body: {"file": licensePath});
    
  var file = File(licensePath);
  var request = MultipartRequest(
    'POST',
    Uri.parse(url+add),
  );
  request.headers['Authorization'] = 'Basic $encoded';
  request.files.add(
    MultipartFile.fromBytes(
      'file',
      file.readAsBytesSync(),
      filename: 'file.img',
      contentType: MediaType('application', 'img'),
    ),
  );

  var response = await request.send();
    var responseBody = await response.stream.transform(utf8.decoder).join();
    print('Response Body $responseBody');
    prefs.setString('privateKey', 'true');
    prefs.setBool('Rider', false);
    print(prefs.getKeys());
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Center(child: Text('Driver Home Page')),
        ));
    return "Text";
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(children: [
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
                      decoration: const InputDecoration(
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
                  ),
                  ElevatedButton.icon(
                    onPressed: () async{
                      // do something
                      final licenseFile = await picker.pickImage(source: ImageSource.gallery);
                      print(licenseFile?.path);
                      setState(()  {licenseText = 'License Uploaded';
                      licensePath = licenseFile?.path;
                      });
                    },
                    icon: Icon(Icons.upload),
                    label: Text(licenseText),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async{
                      // do something
                      final rcFile = await picker.pickImage(source: ImageSource.gallery);
                      print(rcFile?.path);
                      setState(() => rcText = 'RC Uploaded');
                    },
                    icon: Icon(Icons.upload),
                    label: Text(rcText),
                  )
                ]),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  print(submitSignUpDetails(
                    name,
                    phoneNumber,
                    privateKey,
                    licensePath,
                    124
                  ));
                },
                child: Text('SignUp As A Driver')),
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUp()));
                },
                child: Text('SignUp as Rider'))
          ],
        ),
      ),
    );
  }
}
