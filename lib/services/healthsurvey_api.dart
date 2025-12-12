import 'dart:convert';
import 'package:http/http.dart' as http;

class HealthApi {
  static const String baseUrl = "http://172.20.10.8:8000/api";

  static Future<Map<String, dynamic>> submitReport({
    required int healthRating,
    required String areaAffected,
    required List<String> symptoms,
    required DateTime dateStarted,
    required int painRating,
    required String painLocation,
    required bool medicationTaken,
    DateTime? schedule,
  }) async {
    final body = {
      "health_report": {
        "health_rating": healthRating,
        "areaAffected": areaAffected,
        "symptoms": symptoms,
        "date_started": dateStarted.toIso8601String(),
        "pain_rating": painRating,
        "pain_location": painLocation,
        "medication_taken": medicationTaken,
        "schedule": schedule?.toIso8601String(),
      },
    };

    final response = await http.post(
      Uri.parse('$baseUrl/healthSurvey'),
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
}
