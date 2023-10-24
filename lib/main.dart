import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
/*

HEy everyone , today we are going to seee how to integrate PAYTM payment gateway in flutter
paytm integration can be divided into 3 parts
1 -> txToken generation
2 -> checkout
3 -> payment status verification

first let's see backend set up
1st txtoken generation


let's see UI

we got a textfield and a button
here
you have to enter amount click button, on click token generation api 
that's all let's see complete code then demo
before that there are some platform spefici thing
let's see it in action
thanks for watching
*/

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paytm Integration"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.currency_rupee),
                  hintText: "Enter payable amount",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  String amount = _controller.text.trim();
                  if (amount.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Enter amount"),
                      ),
                    );
                    return;
                  }
                  initiateTransaction(amount);
                },
                child: const Text("Pay"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initiateTransaction(String amount) async {
    Map<String, dynamic> body = {
      'amount': amount,
    };

    var parts = [];
    body.forEach((key, value) {
      parts.add('${Uri.encodeQueryComponent(key)}='
          '${Uri.encodeQueryComponent(value)}');
    });
    var formData = parts.join('&');
    var res = await http.post(
      Uri.https(
        "wishufashion.com", // my ip address , localhost
        "paytm/generate_token.php",
      ),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded", // urlencoded
      },
      body: formData,
    );

    print(res.body);
    print(res.statusCode);
    if (res.statusCode == 200) {
      var bodyJson = jsonDecode(res.body);
      final orderId=bodyJson['orderId'];
      //  on success of txtoken generation api
      //  start transaction
      print(bodyJson['mid']);
      print(bodyJson['orderId']);
      print(amount);
      print(bodyJson['txnToken']);

      var response = AllInOneSdk.startTransaction(
        bodyJson['mid'], // merchant id  from api
        bodyJson['orderId'], // order id from api
        amount, // amount
        // bodyJson['txnToken'], // transaction token from api
        "WafCtzD8ahb4BZIi/iNeQiOZ7lkU+LsnnOcQFwwk/wiX8GgCwWE8mPtlpHxsftXTex/b00vF0w7yzJUrJuWhTOruibI35yrX7idI3J8hvug=",
        "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId", // callback url
        true, // isStaging
        false, // restrictAppInvoke
      ).
      then((value) {
        //  on payment completion we will verify transaction with transaction verify api
        //  after payment completion we will verify this transaction
        //  and this will be final verification for payment

        print('raja');
        print(value);
        verifyTransaction(bodyJson['orderId']);
      }).catchError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
          ),
        );
      });
      print(response);
      print('response');
    } else {
    print('ajay');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.body),
        ),
      );
    }
  }

  void verifyTransaction(String orderId) async {
    Map<String, dynamic> body = {
      'orderId': orderId,
    };

    var parts = [];
    body.forEach((key, value) {
      parts.add('${Uri.encodeQueryComponent(key)}='
          '${Uri.encodeQueryComponent(value)}');
    });
    var formData = parts.join('&');
    var res = await http.post(
      Uri.https(
        "wishufashion.com", // my ip address , localhost
        "paytm/verify_transaction.php", // let's check verifycation code on backend
      ),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded", // urlencoded
      },
      body: formData,
    );

    print(res.body);
    print(res.statusCode);
// json decode
    var verifyJson = jsonDecode(res.body);
//  display result info > result msg

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(verifyJson['body']['resultInfo']['resultMsg']),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
