import 'dart:convert';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:eventify/dashboard/organizer_dashboard.dart';
import 'package:eventify/models/Event.dart';
import 'package:eventify/networking/api.dart';
import 'package:eventify/models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uuid/uuid.dart';

import 'homepage.dart';

class CreateEvent extends StatefulWidget {
  final User user;

  const CreateEvent({Key? key, required this.user}) : super(key: key);

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final dateTimeController = TextEditingController();
  final eventTitleController = TextEditingController();
  final eventDescController = TextEditingController();
  final eventVenueController = TextEditingController();
  final eventCapacityController = TextEditingController();

  // String eventId = "";
  // String eventTitle = "";
  // String eventDesc = "";
  // String eventVenue = "";
  // String eventCapacity = "";

  String eventDate = "";
  String eventTime = "";

  String eventImage = "";

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.user.name}"),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                // margin: EdgeInsets.symmetric(vertical: 10),
                // height: 30,
                child: OutlinedButton(
                    style:
                        OutlinedButton.styleFrom(backgroundColor: Colors.white),
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
              ),
              Text("Logged in as: ${widget.user.profile}"),
            ],
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
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
          height: 500,
          child: loading == true
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Creating new event",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      eventTitleController.text,
                      style: TextStyle(fontSize: 20),
                    ),
                    CircularProgressIndicator(),
                    Text(
                      "Please wait...",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: const [
                        Text(
                          "Create new event",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: eventTitleController,
                      decoration:
                          const InputDecoration(labelText: "Event title"),
                    ),
                    TextField(
                      controller: eventDescController,
                      decoration:
                          InputDecoration(labelText: "Event description"),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: eventCapacityController,
                      decoration: InputDecoration(
                        labelText: "Event capacity",
                      ),
                    ),
                    DateTimePicker(
                      type: DateTimePickerType.dateTimeSeparate,
                      dateMask: 'd MMM, yyyy',
                      controller: dateTimeController,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      // icon: const Icon(Icons.event),
                      dateLabelText: "Event date",
                      timeLabelText: "Event time",
                      onChanged: (val) => setState(() {
                        eventDate =
                            "${val[8]}${val[9]}/${val[5]}${val[6]}/${val.substring(0, 4)}";
                        if (val.length > 10) {
                          eventTime = val.substring(11, 16);
                        }
                      }),
                    ),
                    TextField(
                      controller: eventVenueController,
                      decoration:
                          const InputDecoration(labelText: "Event venue"),
                    ),
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: eventImage == ""
                          ? OutlinedButton(
                              child: Text("Upload event poster"),
                              onPressed: () {
                                uploadFile();
                              },
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.done,
                                  color: Colors.green,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Image uploaded successfully."),
                              ],
                            ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: (() => createNewEvent()),
                        child: const Text("Create"),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void uploadFile() async {
    var imageBytes = await ImagePickerWeb.getImageAsBytes();
    if (imageBytes != null) {
      setState(() {
        eventImage = base64Encode(imageBytes.toList());
      });
    }
  }

  void createNewEvent() async {
    setState(() {
      loading = true;
    });

    if (eventTitleController.text == "" ||
        eventDescController.text == "" ||
        eventCapacityController.text == "" ||
        eventDate == "" ||
        eventTime == "" ||
        eventVenueController.text == "" ||
        eventImage == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("All fields are required"),
        ),
      );
    } else {
      Event newEvent = Event(
        event_id: Uuid().v4(),
        event_title: eventTitleController.text,
        event_description: eventDescController.text,
        event_organizer_email: widget.user.email,
        event_start_date: eventDate,
        event_start_time: eventTime,
        event_venue: eventVenueController.text,
        event_isApproved: false,
        event_participants: [],
        event_max_capacity: eventCapacityController.text,
        event_availability: true,
        event_image_body: eventImage,
        event_isRejected: false,
      );

      Map<String, dynamic> eventData = {
        "event_id": newEvent.event_id,
        "event_title": newEvent.event_title,
        "event_description": newEvent.event_description,
        "event_organizer_email": newEvent.event_organizer_email,
        "event_start_time": newEvent.event_start_time,
        "event_start_date": newEvent.event_start_date,
        "event_venue": newEvent.event_venue,
        "event_s3_url":
            "${EventifyAPIs.S3_BUCKET_URL}${newEvent.event_id}.jpeg",
        "event_isApproved": newEvent.event_isApproved,
        "event_participants": newEvent.event_participants,
        "event_max_capacity": newEvent.event_max_capacity,
        "event_availability": newEvent.event_availability,
        "event_image_name": newEvent.event_id,
        "event_image_body": newEvent.event_image_body,
        "event_isRejected": newEvent.event_isRejected
      };

      var response = await EventifyAPIs.makePostRequest(
          "${EventifyAPIs.API_URL}/create-event", eventData);

      print(response);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Event created successfully"),
        ),
      );

      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: OrganizerDashboard(user: widget.user),
        ),
      );
    }
    setState(() {
      loading = false;
    });
  }
}
