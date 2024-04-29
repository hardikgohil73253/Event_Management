import 'package:eventify/homepage.dart';
import 'package:eventify/networking/api.dart';
import 'package:eventify/user_management/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SignUpSucess extends StatefulWidget {
  final Map<String, String> verificationData;

  const SignUpSucess({Key? key, required this.verificationData})
      : super(key: key);

  @override
  State<SignUpSucess> createState() => _SignUpSucessState();
}

class _SignUpSucessState extends State<SignUpSucess> {
  // bool loading = true;

  String titleText = "Please wait";
  String messageText = "";

  @override
  void initState() {
    verifyEmail();
    super.initState();
  }

  void verifyEmail() async {
    EventifyAPIs.makePostRequest(
            "${EventifyAPIs.API_URL}/confirmregister", widget.verificationData)
        .then((response) {
      // print(response);

      if (response["statusCode"] == "200") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(response["message"]),
          ),
        );

        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const HomePage(),
          ),
        );

        // Email verified
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(response["message"]),
          ),
        );

        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const SignUpPage(),
          ),
        );

        // Email not verified
      }
      // setState(() {
      //   loading = false;
      // });
    });

    // if (response.statusCode == 200) {
    //   debugPrint(await response.stream.bytesToString());
    //   setState(() {
    //     titleText = "Email verified successfully.";
    //     messageText = "You can now login with registered email and password";
    //   });
    // } else if (response.statusCode == 201) {
    //   setState(() {
    //     titleText = "User already exists.";
    //     messageText =
    //         "A user already found with email\n${widget.verificationData['username']}";
    //   });
    // } else if (response.statusCode == 202) {
    //   setState(() {
    //     titleText = "Email verification failed";
    //     messageText =
    //         "The code you entered does not match with one that has been sent to:\n${widget.verificationData['username']}";
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Eventify Application"),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 150),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            // color: Colors.red,
            width: 500,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  titleText,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                Text(
                  messageText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
