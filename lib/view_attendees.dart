import 'package:eventify/homepage.dart';
import 'package:eventify/models/Event.dart';
import 'package:eventify/models/User.dart';
import 'package:eventify/networking/api.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ViewAttendees extends StatefulWidget {
  final Event event;
  final User user;

  const ViewAttendees({Key? key, required this.event, required this.user})
      : super(key: key);

  @override
  State<ViewAttendees> createState() => _ViewAttendeesState();
}

class _ViewAttendeesState extends State<ViewAttendees> {
  // bool eventSelected = false;
  List<User> attendees = [];
  bool loading = false;
  // String decisionText = "";

  @override
  void initState() {
    super.initState();
    loadAttendees();
  }

  void loadAttendees() async {
    setState(() {
      loading = true;
    });
    var response = await EventifyAPIs.makeGetRequest(
        "${EventifyAPIs.API_URL}/get-participants?event_id=${widget.event.event_id}");
    print(response);
    setState(() {
      attendees = [];
    });
    for (var user in response["participants"]) {
      User newUser = new User(
          username: "dummy",
          name: user["name"],
          email: user["email"],
          birthDate: "dummy",
          profile: "");
      attendees.add(newUser);
    }
    // for (var event in response["events"]) {
    //   Event newEvent = new Event(
    //       event_id: event["event_id"],
    //       event_title: event["event_title"],
    //       event_description: event["event_description"],
    //       event_organizer_email: event["event_organizer_email"],
    //       event_start_date: event["event_start_date"],
    //       event_start_time: event["event_start_time"],
    //       event_venue: event["event_venue"],
    //       event_isApproved: event["event_isApproved"],
    //       event_participants: event["event_participants"],
    //       event_max_capacity: event["event_max_capacity"],
    //       event_availability: event["event_availability"],
    //       event_image_body: "Event's dummy image body",
    //       event_isRejected: event["event_isRejected"]);
    //   events.add(newEvent);
    // }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Text("Welcome, ${widget.user.name}"),

        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () {
                          loadAttendees();
                        },
                        child: Text(
                          "Refresh",
                          style: TextStyle(color: Colors.white),
                        )),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: HomePage(),
                            ),
                            (route) => false);
                      },
                      child: Text(
                        "Log out",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              Text("Logged in as: ${widget.user.profile}"),
            ],
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: loading == true
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Loading attendees...",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 40,
                ),
                CircularProgressIndicator(),
                SizedBox(
                  height: 40,
                ),
                Text(
                  "Please wait",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ))
          : Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 50),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Attendess for event: ${widget.event.event_title}",
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                  // ignore: sized_box_for_whitespace
                  attendees.length == 0
                      ? Padding(
                          padding: const EdgeInsets.only(top: 200),
                          child: Center(
                              child: Text(
                            "No attendees to display",
                            style: TextStyle(fontSize: 20),
                          )),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: attendees.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  height: 100,
                                  child: Center(
                                    child: ListTile(
                                      title: Text(attendees[index].name),
                                      leading: const Icon(
                                          Icons.account_circle_outlined),
                                      onTap: null,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
