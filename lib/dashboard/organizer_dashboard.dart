import 'package:eventify/create_event.dart';
import 'package:eventify/homepage.dart';
import 'package:eventify/models/User.dart';
import 'package:eventify/models/Event.dart';
import 'package:eventify/networking/api.dart';
import 'package:eventify/view_attendees.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class OrganizerDashboard extends StatefulWidget {
  final User user;

  const OrganizerDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  bool eventSelected = false;
  List<Event> events = [];
  bool loading = false;
  String decisionText = "";
  bool deleteLoading = false;

  Event selected_event = Event(
    event_id: "",
    event_title: "",
    event_description: "",
    event_organizer_email: "",
    event_start_date: "",
    event_start_time: "",
    event_venue: "",
    event_isApproved: false,
    event_participants: [],
    event_max_capacity: "0",
    event_availability: true,
    event_image_body: "dummy",
    event_isRejected: false,
  );

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  void loadEvents() async {
    setState(() {
      loading = true;
      events = [];
    });

    var response = await EventifyAPIs.makeGetRequest(
        "${EventifyAPIs.API_URL}/get-organizer-event?organizer_email=${widget.user.email}");
    // print(response);
    for (var event in response["events"]) {
      Event newEvent = new Event(
          event_id: event["event_id"],
          event_title: event["event_title"],
          event_description: event["event_description"],
          event_organizer_email: event["event_organizer_email"],
          event_start_date: event["event_start_date"],
          event_start_time: event["event_start_time"],
          event_venue: event["event_venue"],
          event_isApproved: event["event_isApproved"],
          event_participants: event["event_participants"],
          event_max_capacity: event["event_max_capacity"],
          event_availability: event["event_availability"],
          event_image_body: "Event's dummy image body",
          event_isRejected: event["event_isRejected"]);
      events.add(newEvent);
    }
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
                // margin: EdgeInsets.symmetric(vertical: 10),
                // height: 30,
                child: Row(
                  children: [
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () {
                          loadEvents();
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
                          // Navigator.pushAndRemoveUntil(

                          // );
                        },
                        child: Text(
                          "Log out",
                          style: TextStyle(color: Colors.red),
                        )),
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
                  "Loading events...",
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
          : Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Your events",
                                style: TextStyle(fontSize: 25),
                              ),
                              SizedBox(
                                height: 40,
                                width: 200,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.fade,
                                        child: CreateEvent(
                                          user: widget.user,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Create new event",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ignore: sized_box_for_whitespace
                        events.length == 0
                            ? Center(
                                child: Text(
                                "No events to display",
                                style: TextStyle(fontSize: 20),
                              ))
                            : Expanded(
                                child: ListView.builder(
                                  itemCount: events.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
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
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        height: 100,
                                        child: Center(
                                          child: ListTile(
                                            title:
                                                Text(events[index].event_title),
                                            leading: const Icon(
                                                Icons.event_available),
                                            onTap: () {
                                              setState(() {
                                                selected_event = events[index];
                                                eventSelected = true;
                                                if (selected_event
                                                            .event_isRejected ==
                                                        false &&
                                                    selected_event
                                                            .event_isApproved ==
                                                        false) {
                                                  decisionText =
                                                      "Pending decision from Admin";
                                                } else if (selected_event
                                                        .event_isRejected ==
                                                    true) {
                                                  decisionText =
                                                      "Your event is rejected by Admin";
                                                } else if (selected_event
                                                        .event_isApproved ==
                                                    true) {
                                                  decisionText =
                                                      "Your event is approved by Admin";
                                                }
                                              });
                                            },
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
                ),
                Expanded(
                    flex: 1,
                    child: AnimatedContainer(
                      curve: Curves.bounceInOut,
                      duration: Duration(milliseconds: 3000),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      child: eventSelected
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selected_event.event_title,
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                    Row(
                                      children: [
                                        decisionText.contains("approved")
                                            ? SizedBox(
                                                height: 40,
                                                width: 150,
                                                child: OutlinedButton(
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      side: BorderSide(
                                                          // width: 5.0,
                                                          color: Colors.blue),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        PageTransition(
                                                          type:
                                                              PageTransitionType
                                                                  .fade,
                                                          child: ViewAttendees(
                                                              event:
                                                                  selected_event,
                                                              user:
                                                                  widget.user),
                                                        ),
                                                      );
                                                    },
                                                    child:
                                                        Text("View attendees")),
                                              )
                                            : Container(),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          height: 40,
                                          width: 100,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.red),
                                            onPressed: () {
                                              deleteEvent();
                                            },
                                            child: deleteLoading
                                                ? SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Text(
                                                    "Delete",
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // const SizedBox(
                                //   height: 20,
                                // ),

                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  width: double.infinity,
                                  height: 300,
                                  child: Image.network(
                                    selected_event.event_s3_url,
                                    // width: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                // fallbackWidth: 200,

                                // const SizedBox(
                                //   height: 20,
                                // ),
                                Text(
                                  selected_event.event_description,
                                  style: TextStyle(fontSize: 15),
                                ),
                                // const SizedBox(
                                //   height: 20,
                                // ),
                                Text(
                                  "Organizer: ${selected_event.event_organizer_email}",
                                  style: TextStyle(fontSize: 18),
                                ),
                                // const SizedBox(
                                //   height: 20,
                                // ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Start Date: ${selected_event.event_start_date}",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Text(
                                      "Start Time: ${selected_event.event_start_time}",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Venue: ${selected_event.event_venue}",
                                  style: TextStyle(fontSize: 18),
                                ),

                                Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    child: Center(
                                        child: Text(
                                      decisionText,
                                      style: TextStyle(fontSize: 20),
                                    ))),
                              ],
                            )
                          : const Center(
                              child: Text(
                                "Select any events from left pane to show details",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                    ))
              ],
            ),
    );
  }

  void deleteEvent() async {
    setState(() {
      deleteLoading = true;
    });

    var response = await EventifyAPIs.makePostRequest(
        "${EventifyAPIs.API_URL}/delete-event",
        {"event_id": selected_event.event_id});
    print(response);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            response["statusCode"] == "200" ? Colors.green : Colors.red,
        content: Text(response["message"]),
      ),
    );
    loadEvents();

    setState(() {
      deleteLoading = false;
      eventSelected = false;
    });
  }
}
