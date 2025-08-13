import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class SearchService {
  /// Finds location via OpenStreetMap
  static Future<LatLng?> getCoordinates(String place) async {
    try {
      final encodedPlace = Uri.encodeComponent(place);
      final url =
          "https://nominatim.openstreetmap.org/search?q=$encodedPlace&format=json";

      final response =
          await http.get(Uri.parse(url), headers: {'User-Agent': 'FlutterApp'});

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);

        if (jsonList.isNotEmpty) {
          final lat = double.parse(jsonList[0]["lat"]);
          final lon = double.parse(jsonList[0]["lon"]);
          return LatLng(lat, lon);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
