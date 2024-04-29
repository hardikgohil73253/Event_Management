import 'package:eventify/networking/api.dart';

class Event {
  late String event_id;
  late String event_s3_url;
  late String event_title;
  late String event_description;
  late String event_organizer_email;
  late String event_start_date;
  late String event_start_time;
  late String event_venue;
  late bool event_isApproved;
  late List<dynamic> event_participants;
  late String event_max_capacity;
  late bool event_availability;
  late String event_image_body;
  late bool event_isRejected;

  Event({
    required this.event_id,
    required this.event_title,
    required this.event_description,
    required this.event_organizer_email,
    required this.event_start_date,
    required this.event_start_time,
    required this.event_venue,
    required this.event_isApproved,
    required this.event_participants,
    required this.event_max_capacity,
    required this.event_availability,
    required this.event_image_body,
    required this.event_isRejected,
  }) {
    this.event_s3_url = EventifyAPIs.S3_BUCKET_URL + this.event_id + ".jpeg";
  }
}
