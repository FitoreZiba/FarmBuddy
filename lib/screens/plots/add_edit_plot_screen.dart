import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../models/plot.dart';
import '../../providers/auth_provider.dart';
import '../../providers/plot_provider.dart';
import '../../theme/app_theme.dart';

class AddEditPlotScreen extends StatefulWidget {
  final Plot? existing;
  const AddEditPlotScreen({super.key, this.existing});

  @override
  State<AddEditPlotScreen> createState() => _AddEditPlotScreenState();
}

class _AddEditPlotScreenState extends State<AddEditPlotScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _area;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  String? _soilType;
  double? _lat;
  double? _lng;
  bool _locating = false;
  bool _mapExpanded = false;
  String? _locationError;

  static const _soilOptions = ['Loam', 'Clay', 'Sandy', 'Silt', 'Peaty', 'Chalky'];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _area = TextEditingController(text: widget.existing?.areaSqMeters?.toString() ?? '');
    _lat = widget.existing?.latitude;
    _lng = widget.existing?.longitude;
    _latCtrl = TextEditingController(text: _lat?.toStringAsFixed(6) ?? '');
    _lngCtrl = TextEditingController(text: _lng?.toStringAsFixed(6) ?? '');
    _soilType = widget.existing?.soilType;
  }

  void _setLocation(double lat, double lng) {
    setState(() {
      _lat = lat;
      _lng = lng;
      _latCtrl.text = lat.toStringAsFixed(6);
      _lngCtrl.text = lng.toStringAsFixed(6);
      _locationError = null;
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() { _locating = true; _locationError = null; });
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are off');
      }
      final pos = await Geolocator.getCurrentPosition();
      _setLocation(pos.latitude, pos.longitude);
      setState(() => _mapExpanded = true);
    } catch (e) {
      setState(() => _locationError = e.toString());
    } finally {
      setState(() => _locating = false);
    }
  }

  void _applyManualCoords() {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null ||
        lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      setState(() => _locationError = 'Enter valid coordinates');
      return;
    }
    _setLocation(lat, lng);
    setState(() => _mapExpanded = true);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null || _lng == null) {
      setState(() => _locationError = 'Set a location first');
      return;
    }
    final uid = context.read<AuthProvider>().user!.uid;
    final provider = context.read<PlotProvider>();
    final area = double.tryParse(_area.text.trim());

    if (widget.existing == null) {
      await provider.addPlot(
        userId: uid,
        name: _name.text.trim(),
        latitude: _lat!,
        longitude: _lng!,
        areaSqMeters: area,
        soilType: _soilType,
      );
    } else {
      await provider.updatePlot(widget.existing!.copyWith(
        name: _name.text.trim(),
        latitude: _lat,
        longitude: _lng,
        areaSqMeters: area,
        soilType: _soilType,
      ));
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add plot' : 'Edit plot')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Plot name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _area,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Area (m²) — optional'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _soilType,
                  decoration: const InputDecoration(labelText: 'Soil type'),
                  items: _soilOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _soilType = v),
                ),

                const SizedBox(height: 22),
                const Text('Location',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _locating ? null : _useCurrentLocation,
                  icon: _locating
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location_rounded),
                  label: const Text('Use my current GPS location'),
                ),

                const SizedBox(height: 10),
                const Row(children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('or', style: TextStyle(color: Colors.black38)),
                  ),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        decoration: const InputDecoration(labelText: 'Latitude'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _lngCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        decoration: const InputDecoration(labelText: 'Longitude'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _applyManualCoords,
                      icon: const Icon(Icons.check_circle_rounded,
                          color: AppColors.leafGreen, size: 30),
                      tooltip: 'Apply coordinates',
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Tip: search the location on Google Maps, long-press to copy coordinates.',
                    style: TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                ),

                const SizedBox(height: 10),
                const Row(children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('or', style: TextStyle(color: Colors.black38)),
                  ),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: 10),

                OutlinedButton.icon(
                  onPressed: () => setState(() => _mapExpanded = true),
                  icon: const Icon(Icons.map_rounded),
                  label: const Text('Pick location on map'),
                ),

                if (_locationError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_locationError!,
                        style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                  ),

                if (_mapExpanded) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Tap anywhere on the map to place the plot pin.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 260,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _lat != null
                              ? LatLng(_lat!, _lng!)
                              : const LatLng(41.9981, 21.4254), 
                          initialZoom: _lat != null ? 14 : 6,
                          onTap: (tapPos, point) {
                            _setLocation(point.latitude, point.longitude);
                          },
                        ),
                        children: [
                        TileLayer(
                          urlTemplate:
                            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.example.farmbuddy',
                        ),
                          if (_lat != null)
                            MarkerLayer(markers: [
                              Marker(
                                point: LatLng(_lat!, _lng!),
                                width: 36,
                                height: 36,
                                child: const Icon(Icons.location_on_rounded,
                                    color: AppColors.ripeGold, size: 36),
                              ),
                            ]),
                        ],
                      ),
                    ),
                  ),
                  if (_lat != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Pin: ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                ],

                const SizedBox(height: 28),
                ElevatedButton(onPressed: _save, child: const Text('Save plot')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
