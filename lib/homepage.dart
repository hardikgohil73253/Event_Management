import 'package:eventify/dashboard/admin_dashboard.dart';
import 'package:eventify/dashboard/attendee_dashboard.dart';
import 'package:eventify/dashboard/organizer_dashboard.dart';
import 'package:eventify/models/User.dart';
import 'package:eventify/user_management/signup_page.dart';
import 'package:eventify/networking/api.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  void login() {
    EventifyAPIs.makePostRequest('${EventifyAPIs.API_URL}/login', {
      "username": emailController.text,
      "password": passwordController.text
    }).then((response) {
      if (response["statusCode"] == "200") {
        // print(response);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Login successful."),
          ),
        );

        if (response["profile"] == "attendee") {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: AttendeeDashboard(
                  user: User(
                username: response['username'],
                name: response['name'],
                email: response['email'],
                birthDate: response['dob'],
                profile: response['profile'],
              )),
            ),
          );
        } else if (response["profile"] == "organizer") {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: OrganizerDashboard(
                  user: User(
                username: response['username'],
                name: response['name'],
                email: response['email'],
                birthDate: response['dob'],
                profile: response['profile'],
              )),
            ),
          );
        } else if (response["profile"] == "admin") {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: AdminDashboard(
                  user: User(
                username: response['username'],
                name: response['name'],
                email: response['email'],
                birthDate: response['dob'],
                profile: response['profile'],
              )),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Login failed. Please check your credentials."),
          ),
        );
      }
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Eventify Application"),
      ),
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
                height: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: const [
                        Text(
                          "Login here",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    loading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  label: Text("Enter email address"),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    label: Text("Enter your password")),
                              ),
                            ],
                          ),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: (() {
                          if (emailController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("All fields are required"),
                              ),
                            );
                          } else {
                            setState(() {
                              loading = true;
                            });
                            login();
                          }
                        }),
                        child: const Text("Login"),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: const SignUpPage(),
                            ),
                          ),
                          child: const Text("New user?"),
                        ),
                      ],
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
