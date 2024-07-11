import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson75/services/location_servcice.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late YandexMapController mapController;
  Point? selectedPoint;
  Point currentPoint = const Point(latitude: 45.62854, longitude: 45.6695);
  List<MapObject>? routePointes;

  TextEditingController _searchController = TextEditingController();

  onMapController(YandexMapController controller) {
    mapController = controller;
    mapController.moveCamera(
      animation: const MapAnimation(
        duration: 0.5,
        type: MapAnimationType.smooth,
      ),
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentPoint),
      ),
    );
  }

  getLiveLocation() {
    LocationServcice.getCurrentLocation().listen((position) {
      currentPoint = Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      setState(() {});
    });
  }

  Future<void> _searchLocation() async {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          Location loc = locations.first;
          Point newPoint = Point(latitude: loc.latitude, longitude: loc.longitude);
          mapController.moveCamera(
            animation: const MapAnimation(
              duration: 0.5,
              type: MapAnimationType.smooth,
            ),
            CameraUpdate.newCameraPosition(
              CameraPosition(target: newPoint, zoom: 15),
            ),
          );
          selectedPoint = newPoint;
          LocationServcice.getDirection(currentPoint, selectedPoint!).then((points) {
            routePointes = points;
            print(routePointes!.length);
            setState(() {});
          });
          setState(() {});
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getLiveLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapTap: (argument) {
              selectedPoint = argument;
              LocationServcice.getDirection(currentPoint, selectedPoint!).then((points) {
                routePointes = points;
                setState(() {});
              });

              setState(() {});
            },
            mapType: MapType.map,
            fastTapEnabled: true,
            onMapCreated: onMapController,
            mapObjects: [
              PlacemarkMapObject(
                icon: PlacemarkIcon.single(PlacemarkIconStyle(image: BitmapDescriptor.fromAssetImage('assets/place.png'))),
                mapId: const MapObjectId("currentLocation"),
                point: currentPoint,
              ),
              if (selectedPoint != null)
                PlacemarkMapObject(
                  icon: PlacemarkIcon.single(PlacemarkIconStyle(image: BitmapDescriptor.fromAssetImage('assets/route_end.png'))),
                  mapId: const MapObjectId("selectedLocation"),
                  point: selectedPoint!,
                ),
              ...?routePointes,
            ],
          ),
          Positioned(
            top: 50,
            left: 25,
            right: 25,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter a location',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(CupertinoIcons.search),
                  onPressed: _searchLocation,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 100,
            right: 25,
            child: Column(
              children: [
                InkWell(
                  highlightColor: Colors.blue,
                  onTap: () {
                    mapController.moveCamera(CameraUpdate.zoomIn());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(CupertinoIcons.plus),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  highlightColor: Colors.blue,
                  onTap: () {
                    mapController.moveCamera(CameraUpdate.zoomOut());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(CupertinoIcons.minus),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 25,
            left: 25,
            child: InkWell(
              onTap: () {
                mapController.moveCamera(
                  animation: const MapAnimation(
                    duration: 0.5,
                    type: MapAnimationType.smooth,
                  ),
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: currentPoint, zoom: 15),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyan[400],
                ),
                child: const Icon(
                  CupertinoIcons.location_fill,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
