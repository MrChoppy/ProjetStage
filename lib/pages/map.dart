import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;

class CustomMap extends StatefulWidget {
  final String etudiantAdresse;
  final String stageAdresse;

  const CustomMap(
      {super.key, required this.etudiantAdresse, required this.stageAdresse});

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> with OSMMixinObserver {
  late MapController controller;
  final List<GeoPoint> points = [];
  late GeoPoint etudiant;
  late GeoPoint stage;
  late double distance = 0;

  @override
  void initState() {
    super.initState();
    controller = MapController(
      initPosition: GeoPoint(
        latitude: 42.2330395,
        longitude: -97.0508715,
      ),
    );
    controller.addObserver(this);
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      fetchCoordinates();
    }
  }

  Future<void> fetchCoordinates() async {
    etudiant = (await geocodeAddress(widget.etudiantAdresse))!;
    stage = (await geocodeAddress(widget.stageAdresse))!;

    controller.goToLocation(etudiant);
    await addMarkers();
  }

  Future<GeoPoint?> geocodeAddress(String address) async {
    const baseUrl = 'https://geocode.maps.co/search';
    final formattedAddress = address.replaceAll(' ', '+');

    try {
      final response =
          await http.get(Uri.parse('$baseUrl?q=$formattedAddress'));

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> data =
            (json.decode(response.body) as List<dynamic>)
                .cast<Map<String, dynamic>>();

        if (data.isNotEmpty) {
          final Map<String, dynamic> result = data[0];

          String? latitudeStr = result['lat']?.toString();
          String? longitudeStr = result['lon']?.toString();

          double? latitude = double.tryParse(latitudeStr ?? '');
          double? longitude = double.tryParse(longitudeStr ?? '');

          if (latitude != null && longitude != null) {
            return GeoPoint(latitude: latitude, longitude: longitude);
          } else {
            print('Invalid response format from geocoding service.');
            return null;
          }
        } else {
          print('No results found for address: $address');
          return null;
        }
      } else {
        print(
            'Error geocoding address: $address, Status Code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error geocoding address: $address, Exception: $e');
      return null;
    }
  }

  Future<void> addMarkers() async {
    try {
      //controller.addMarker(etudiant); LE MARKER EST DEJA AJOUTER LORSQUE LE CHEMIN EST TRASSE
      controller.addMarker(stage);

      RoadInfo? roadInfo = await controller.drawRoad(etudiant, stage);
      setState(() {
        distance = roadInfo.distance ?? 0.0;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: OSMFlutter(
            controller: controller,
            osmOption: OSMOption(
              userTrackingOption: const UserTrackingOption(
                enableTracking: true,
                unFollowUser: false,
              ),
              zoomOption: const ZoomOption(
                initZoom: 8,
                minZoomLevel: 3,
                maxZoomLevel: 19,
                stepZoom: 1.0,
              ),
              userLocationMarker: UserLocationMaker(
                personMarker: const MarkerIcon(
                  icon: Icon(
                    Icons.location_history_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                directionArrowMarker: const MarkerIcon(
                  icon: Icon(
                    Icons.double_arrow,
                    size: 48,
                  ),
                ),
              ),
              roadConfiguration: const RoadOption(
                roadColor: Colors.yellowAccent,
              ),
              markerOption: MarkerOption(
                  defaultMarker: const MarkerIcon(
                icon: Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 56,
                ),
              )),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Text(
            'Distance entre vous et la destination: ${distance.toStringAsFixed(2)} km',
            style: const TextStyle(fontSize: 18.0),
          ),
        ),
      ],
    ));
  }
}
