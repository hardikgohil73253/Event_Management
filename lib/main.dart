import 'package:eventify/homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventify',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const HomePage(),
      // home: AdminDashboard(
      //     user: User(
      //   username: "df8939a6-159b-43b4-aa66-c287cabc2dee",
      //   name: "AdminUser",
      //   email: "admin@user.com",
      //   birthDate: "24/11/1998",
      //   profile: "admin",
      // )),
      // home: AttendeeDashboard(
      //     user: User(
      //   username: "d35765f2-7c9f-46ee-a3df-3f0bf56cfcdf",
      //   name: "Harvik",
      //   email: "harvik39@gmail.com",
      //   birthDate: "12/12/2022",
      //   profile: "atendee",
      // )),

      // home: OrganizerDashboard(
      //   user: User(
      //       username: "85f05f32-c9a9-4cce-8c19-f5e1a5bb69e0",
      //       name: "Jay Sonani",
      //       email: "jsonani98@gmail.com",
      //       birthDate: "asd",
      //       profile: "Organizer"),
      // ),
      debugShowCheckedModeBanner: false,
    );
  }
}
