import 'package:flutter/material.dart';
import 'package:eventify/networking/api.dart';
import 'package:eventify/user_management/signup_success.dart';
import 'package:page_transition/page_transition.dart';

class SignUpVerification extends StatefulWidget {
  final Map<String, String> signupData;

  const SignUpVerification({Key? key, required this.signupData})
      : super(key: key);

  @override
  State<SignUpVerification> createState() => _SignUpVerificationState();
}

class _SignUpVerificationState extends State<SignUpVerification> {
  bool loading = true;
  String statusCode = "";

  String profile = "";
  int radioValue = -1;

  final codeController = TextEditingController();

  @override
  void initState() {
    signUp();
    super.initState();
  }

  void signUp() async {
    EventifyAPIs.makePostRequest('${EventifyAPIs.API_URL}/register', {
      "username": widget.signupData["username"],
      "password": widget.signupData["password"],
      "firstname": widget.signupData["firstname"],
      "lastname": widget.signupData["lastname"],
      "birthdate": widget.signupData["birthdate"],
      "profile": widget.signupData["profile"],
    }).then((response) {
      setState(() {
        statusCode = response["statusCode"];
      });
      if (statusCode == "200") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(response['message']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(response['message']),
          ),
        );
      }

      // print(response);

      setState(() {
        loading = false;
      });
    });
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
                loading
                    ? const Text(
                        "Please wait",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )
                    : const Text(
                        "Enter verification code",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                !loading
                    ? Text(
                        "A verification code has been successfully sent to:\n${widget.signupData['username']}")
                    : Container(),
                !loading
                    ? TextField(
                        controller: codeController,
                        decoration: const InputDecoration(
                            hintText: "Enter 6-digit code"),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                !loading
                    ? SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: (() {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                child: SignUpSucess(verificationData: {
                                  "username":
                                      "${widget.signupData['username']}",
                                  "code": codeController.text,
                                }),
                              ),
                            );
                          }),
                          child: const Text("Verify"),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
