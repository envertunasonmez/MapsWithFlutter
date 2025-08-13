import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_with_flutter/search_service.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = const LatLng(41.0082, 28.9784); // Istanbul coordinates
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _searchAndNavigate(String place) async {
    try {
      final pos = await SearchService.getCoordinates(place);

      if (pos != null) {
        // Add marker for the searched place
        _markers.clear();
        _markers.add(Marker(
          markerId: MarkerId(place),
          position: pos,
          infoWindow: InfoWindow(title: place),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
        setState(() {});

        // Animate camera to the new position
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(pos, 16),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("location did not found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "search place...",
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    _searchAndNavigate(_searchController.text);
                  }
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) _searchAndNavigate(value);
            },
          ),
        ),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 12, // set initial zoom level
        ),
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        markers: _markers,
      ),
    );
  }
}
