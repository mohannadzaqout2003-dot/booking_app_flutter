import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceMapScreen extends StatefulWidget {
  const ServiceMapScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lat,
    required this.lng,
  });

  final String title;
  final String subtitle;
  final double lat;
  final double lng;

  @override
  State<ServiceMapScreen> createState() => _ServiceMapScreenState();
}

class _ServiceMapScreenState extends State<ServiceMapScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  

  LatLng get _point => LatLng(widget.lat, widget.lng);

  Future<void> _openExternalMaps() async {
    final lat = widget.lat;
    final lng = widget.lng;

    // Universal Google Maps directions/search URL
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open maps app')));
    }
  }

  void _center() {
    _mapController.move(_point, 15);
  }

  @override
  Widget build(BuildContext context) {
    final point = _point;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
        actions: [
          IconButton(
            tooltip: 'Open in Maps',
            onPressed: _openExternalMaps,
            icon: const Icon(Icons.directions),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: point,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.booking_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 240,
                    height: 90,
                    alignment: Alignment.topCenter,
                    child: _MarkerBubble(
                      title: widget.title,
                      subtitle: widget.subtitle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _center,
        icon: const Icon(Icons.my_location),
        label: const Text('Center'),
      ),
    );
  }
}

class _MarkerBubble extends StatelessWidget {
  const _MarkerBubble({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6E8F0)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                color: Color(0x22000000),
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: const Icon(Icons.location_on, size: 36, color: Colors.red),
        ),
      ],
    );
  }
}
