import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'secrets.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'maps.dart';

var client;
var credentials;
var abiCode;
var contract;

Future<String> init() async {
  credentials = EthPrivateKey.fromHex(hardPrivateKey);
  client = Web3Client(rpcUrl, Client());
  final byteData = await rootBundle.load('assets/Abi/abi.json');
  abiCode = utf8.decode(byteData.buffer.asUint8List());
  print('end of init');

  contract = DeployedContract(ContractAbi.fromJson(abiCode, 'RiderBooking'),
      rideBookingcontractAddress);

  return 'Null';
}

Future<String> requestRide(srcLat, srcLong, destLat, destLong, distance) async {
  await init();
  print("After Init");

  final requestRide = contract.function("requestRide");

  final hash = await client.sendTransaction(
      credentials,
      Transaction.callContract(
          contract: contract,
          function: requestRide,
          parameters: [srcLat, srcLong, destLat, destLong, distance], maxGas: 1000000),
      chainId: 11155111);

  print("Request Ride Hash: $hash");
  return hash;
}

// void getDrivers( widgetList) {
//   setState((){});
// }

Future<BigInt> getCurrentRideId() async{
  await init();

  final getCurrentRideId = contract.function("getCurrentRideofRider");

  var rideId = await client.call(sender: publicKey, contract: contract, function: getCurrentRideId, params: []);
  print("Ride Id: ${rideId.first}");
  return rideId.first;
}

Future<void> selectDriver(rideId, bidIndex) async{
  await init();

  final selectDriver = contract.function('selectDriver');

  String hash = await client.sendTransaction(credentials, Transaction.callContract(
    contract: contract,
    function: selectDriver,
    parameters: [rideId, bidIndex]
  ),
  chainId: 11155111
  );
}

Future<void> signUp(name, phoneNumber) async {
  await init();
  final createRider = contract.function('createRider');
  final getRiders = contract.function('getRiders');

  // final drivers = await client.call(contract: contract, function: getRiders, params: [], sender: EthereumAddress.fromHex("0x125082a11d11d66a8c85590ec69df5769f1ef8a3"));
  String hash = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: createRider,
        parameters: [name, phoneNumber],
      ),
      chainId: 11155111);
  print("Hash of createRider Transaction: $hash");
}

