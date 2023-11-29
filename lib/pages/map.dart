import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

//TODO: AU LIEU D'AVOIR 2 POINTS QU'ON MET, PRENDRE L'ADRESSE DE L'ETUDIANT ET L'ADRESSE DE L'EMPLOYEUR
class Map extends StatefulWidget {
  const Map({super.key});

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> with OSMMixinObserver {
  late MapController controller;
  final List<GeoPoint> points = [];

  @override
  void initState() {
    super.initState();
    controller = MapController(
      initPosition: GeoPoint(
        latitude: 47.4333594,
        longitude: 8.4680184,
      ),
    );

    controller.addObserver(this);
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {}
  }

  @override
  Future<void> onSingleTap(GeoPoint position) async {
    super.onSingleTap(position);
    setState(() {
      if (points.length == 2) {
        points.removeAt(0);
        controller.removeMarker(points[0]);
        //controller.clearAllRoads();
      }
      points.add(position);
      controller.addMarker(position);
    });

    if (points.length == 2) {
      RoadInfo? roadInfo = await controller.drawRoad(points[0], points[1]);

      double distance = roadInfo.distance ?? 0.0;
      print('Distance between points: $distance km');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OSMFlutter(
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
        onGeoPointClicked: (markerId) {
          controller.removeMarker(markerId);
        },
      ),
    );
  }
}
