import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class EveryoneDetailPage extends StatefulWidget {
  const EveryoneDetailPage({super.key});

  @override
  State<EveryoneDetailPage> createState() => _EveryoneDetailPageState();
}

class _EveryoneDetailPageState extends State<EveryoneDetailPage> {
  late MapController mapController;
  var argument = Get.arguments;
  late LatLng latlng;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    latlng = LatLng(argument.lat, argument.lng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: const Row(
              children: [
                Text(
                  "모두가 찾은 맛집 위치",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FlutterMap(
          mapController: mapController,
          options: MapOptions(initialCenter: latlng, initialZoom: 17.0),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(markers: [
              Marker(
                  width: 80,
                  height: 100,
                  point: latlng,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Text(
                          argument.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Icon(
                        Icons.pin_drop,
                        size: 50,
                        color: Colors.red,
                      )
                    ],
                  )),
            ])
          ]),
    );
  }
}
