import 'package:eventify/user_management/signup_verification.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final birthDateController = TextEditingController();
  final passwordController = TextEditingController();
  String profile = "";
  int radioValue = -1;

  Map<String, String> signUpData = {
    "username": "",
    "password": "",
    "firstname": "",
    "lastname": "",
    "birthdate": "",
    "profile": "",
  };

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Eventify",
                    style: TextStyle(fontSize: 50),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    width: 400,
                    child: Wrap(
                      children: const [
                        Text(
                          "End of your search to find events around you.",
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                // color: Colors.red,
                width: 500,
                height: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: const [
                        Text(
                          "Register here",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 210,
                          child: TextField(
                            controller: firstNameController,
                            decoration:
                                const InputDecoration(hintText: "First name"),
                          ),
                        ),
                        SizedBox(
                          width: 210,
                          child: TextField(
                            controller: lastNameController,
                            decoration:
                                const InputDecoration(hintText: "Last name"),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                          hintText: "Enter email address"),
                    ),
                    TextField(
                      controller: birthDateController,
                      decoration: const InputDecoration(
                          hintText: "Enter date of birth(dd/mm/yyyy)"),
                    ),
                    TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: const InputDecoration(
                          hintText: "Create your password"),
                    ),
                    SizedBox(
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text("Select Role:"),
                          Radio(
                            value: 1,
                            groupValue: radioValue,
                            onChanged: (value) {
                              setState(() {
                                radioValue = int.parse(value.toString());
                                profile = "attendee";
                              });
                            },
                          ),
                          const Text("Attendee"),
                          const SizedBox(
                            width: 20,
                          ),
                          Radio(
                            value: 2,
                            groupValue: radioValue,
                            onChanged: (value) {
                              setState(() {
                                radioValue = int.parse(value.toString());
                                profile = "organizer";
                              });
                            },
                          ),
                          const Text("Organizer"),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: (() {
                          signUpData["username"] = emailController.text;
                          signUpData["password"] = passwordController.text;
                          signUpData["firstname"] = firstNameController.text;
                          signUpData["lastname"] = lastNameController.text;
                          signUpData["birthdate"] = birthDateController.text;
                          signUpData["profile"] = profile;
                          // debugPrint(signUpData.toString());

                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: SignUpVerification(
                                signupData: signUpData,
                              ),
                            ),
                          );
                        }),
                        child: const Text("Register"),
                      ),
                    ),
                    TextButton(
                      onPressed: () => {Navigator.pop(context)},
                      child: const Text("Back to Login"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
