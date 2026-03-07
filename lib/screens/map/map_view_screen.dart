import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/listings_provider.dart';
import '../../services/location_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_widget.dart';
import '../directory/listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;

  // Kigali city centre default camera
  static const CameraPosition _kigaliCenter = CameraPosition(
    target: LatLng(-1.9441, 30.0619),
    zoom: 13,
  );

  Set<Marker> _buildMarkers(List<ListingModel> listings) {
    return listings.map((l) {
      final info = l.categoryInfo;
      return Marker(
        markerId: MarkerId(l.id),
        position: LatLng(l.latitude, l.longitude),
        infoWindow: InfoWindow(
          title: l.name,
          snippet: info.label,
          onTap: () => _openDetail(l),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _categoryHue(l.categoryEnum),
        ),
      );
    }).toSet();
  }

  double _categoryHue(AppCategory cat) {
    switch (cat) {
      case AppCategory.hospital:
        return BitmapDescriptor.hueRed;
      case AppCategory.police:
      case AppCategory.rib:
        return BitmapDescriptor.hueBlue;
      case AppCategory.park:
        return BitmapDescriptor.hueGreen;
      case AppCategory.restaurant:
      case AppCategory.cafe:
        return BitmapDescriptor.hueOrange;
      case AppCategory.tourist:
        return BitmapDescriptor.hueYellow;
      case AppCategory.supermarket:
        return BitmapDescriptor.hueCyan;
      case AppCategory.transport:
        return BitmapDescriptor.hueViolet;
      default:
        return BitmapDescriptor.hueRose;
    }
  }

  void _openDetail(ListingModel listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listing: listing),
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position == null || _mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>().listings;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.mapView)),
      body: listings.isEmpty
          ? const LoadingWidget(message: 'Loading map...')
          : GoogleMap(
              initialCameraPosition: _kigaliCenter,
              markers: _buildMarkers(listings),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (c) => _mapController = c,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        tooltip: AppStrings.myLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}