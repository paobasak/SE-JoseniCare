import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentApi {
  static const String baseUrl = "http://172.20.10.8:8000/api";

  static Future<Map<String, dynamic>> createAppointment({
    required String campus,
    required String type,
    required String purpose,
    required String status,
    required DateTime schedule,
  }) async {
    final body = {
      "appointment": {
        "campus": campus,
        "type": type,
        "purpose": purpose,
        "status": status,
        "schedule": schedule.toIso8601String(),
      },
    };

    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result;
    } else {
      return {"success": false, "message": response.body};
    }
  }

  static Future<List<DateTime>> getPendingSlots(String date) async {
    final response = await http.get(
      Uri.parse("$baseUrl/appointments/pending?date=$date"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<DateTime> pending = [];

      for (var slot in data['pending_slots']) {
        pending.add(DateTime.parse(slot['schedule']));
      }

      return pending;
    } else {
      return [];
    }
  }
}
