import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'secrets.dart';
import 'package:http/http.dart';
import 'dart:convert';

Future<String> giveApproval() async {
  final client = Web3Client(rpcUrl, Client());
  // print(cline)
  final credentials = EthPrivateKey.fromHex(hardPrivateKey);
  print("Credentials: ${credentials.address}");
  // final File abiFile = File(p.join(p.dirname(Platform.script.path), 'assets/Abi/abi.json'));

  // print("AbiFile: $abiFile");

  // final abiCode = await rootBundle.loadString('assets/Abi/abi.json');
  final byteData = await rootBundle.load('assets/Abi/tokenabi.json');
  final abiCode = utf8.decode(byteData.buffer.asUint8List());
  // print("Json String: $jsonString");
  final contract = DeployedContract(
      ContractAbi.fromJson(abiCode, 'Token'), tokenContractAddress);
  final balanceOf = contract.function('balanceOf');
  final approve = contract.function('approve');

  final balance = await client.call(contract: contract, function: balanceOf, params: [publicKey]);
  print("Balance: $balance");

  var hash  = await client.sendTransaction(credentials, 
  Transaction.callContract(contract: contract, function: approve, parameters: [rideBookingcontractAddress, BigInt.from(1000)]), chainId: 11155111);
  print('Approval Hash: $hash');
  return hash;


}
