import 'package:eventify/homepage.dart';
import 'package:eventify/models/Event.dart';
import 'package:eventify/models/User.dart';
import 'package:eventify/networking/api.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AttendeeDashboard extends StatefulWidget {
  final User user;

  const AttendeeDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<AttendeeDashboard> createState() => _AttendeeDashboardState();
}

class _AttendeeDashboardState extends State<AttendeeDashboard> {
  bool eventSelected = false;
  List<Event> events = [];
  bool loading = false;
  bool bookingLoading = false;

  // var events = [for (var i = 1; i <= 10; i++) "Event Title $i"];
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
        "${EventifyAPIs.API_URL}/get-approved-event");
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
          : events.length == 0
              ? Center(
                  child: Text(
                  "No events to display",
                  style: TextStyle(fontSize: 20),
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
                        child: ListView.builder(
                          itemCount: events.length,
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
                                    title: Text(events[index].event_title),
                                    leading: const Icon(Icons.event_available),
                                    onTap: () {
                                      setState(() {
                                        selected_event = events[index];
                                        eventSelected = true;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selected_event.event_title,
                                      style: const TextStyle(fontSize: 30),
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

                                    selected_event.event_availability == false
                                        ? Container(
                                            width: double.infinity,
                                            height: 60,
                                            child: Center(
                                                child: Text(
                                              "This event is full.",
                                              style: TextStyle(fontSize: 20),
                                            )),
                                          )
                                        : selected_event.event_participants
                                                .contains(widget.user.username)
                                            ? Container(
                                                width: double.infinity,
                                                height: 60,
                                                child: Center(
                                                    child: Text(
                                                  "You have already booked for this event.",
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                )),
                                              )
                                            : bookingLoading
                                                ? Container(
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  )
                                                : Container(
                                                    width: double.infinity,
                                                    height: 60,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        bookEvent();
                                                      },
                                                      child: Text(
                                                        "Book now",
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                  )
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

  void bookEvent() async {
    await Alert(
      context: context,
      title: "Make a payment for \$25 CAD",
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      content: TextField(
        decoration: InputDecoration(labelText: "Enter your card number"),
      ),
      buttons: [
        DialogButton(
            color: Colors.grey,
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        DialogButton(
            color: Colors.green,
            child: Text(
              "Pay",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                bookingLoading = true;
              });
              var response = await EventifyAPIs.makePostRequest(
                  "${EventifyAPIs.API_URL}/book-event", {
                "event_id": selected_event.event_id,
                "attendee_username": widget.user.username,
                "attendee_email": widget.user.email
              });

              print(response);

              if (response["statusCode"] == "200") {
                setState(() {
                  selected_event.event_participants.add(widget.user.username);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(response["message"]),
                  ),
                );
              } else if (response["statusCode"] == "400") {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.yellow,
                    content: Text(response["message"]),
                  ),
                );
              }

              setState(() {
                bookingLoading = false;
              });
              loadEvents();
            }),
      ],
    ).show();
  }
}
