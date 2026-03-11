import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../services/location_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';

class CreateEditListingScreen extends StatefulWidget {
  final ListingModel? existingListing;
  const CreateEditListingScreen({super.key, this.existingListing});

  @override
  State<CreateEditListingScreen> createState() =>
      _CreateEditListingScreenState();
}

class _CreateEditListingScreenState extends State<CreateEditListingScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;

  late AppCategory _selectedCategory;
  GoogleMapController? _mapController;
  Marker? _pickedMarker;

  // Default Kigali center
  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);

  bool get _isEditMode => widget.existingListing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existingListing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _addressCtrl = TextEditingController(text: e?.address ?? '');
    _contactCtrl = TextEditingController(text: e?.contact ?? '');
    _descriptionCtrl = TextEditingController(text: e?.description ?? '');
    
    final initialLat = e?.latitude;
    final initialLng = e?.longitude;
    
    _latCtrl = TextEditingController(text: initialLat?.toString() ?? '');
    _lngCtrl = TextEditingController(text: initialLng?.toString() ?? '');
    
    if (initialLat != null && initialLng != null) {
      _pickedMarker = Marker(
        markerId: const MarkerId('picked'),
        position: LatLng(initialLat, initialLng),
      );
    }
    
    _selectedCategory = e != null ? e.categoryEnum : AppCategory.other;

    // Listen to manual coordinate changes to update map marker
    _latCtrl.addListener(_updateMarkerFromInputs);
    _lngCtrl.addListener(_updateMarkerFromInputs);
  }

  @override
  void dispose() {
    _latCtrl.removeListener(_updateMarkerFromInputs);
    _lngCtrl.removeListener(_updateMarkerFromInputs);
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _descriptionCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    // On Web, manually disposing the controller can cause an assertion error
    // if the HTML view isn't fully ready. GoogleMap widget handles this cleanup.
    _mapController = null;
    super.dispose();
  }

  void _updateMarkerFromInputs() {
    final lat = double.tryParse(_latCtrl.text);
    final lng = double.tryParse(_lngCtrl.text);
    if (lat != null && lng != null) {
      setState(() {
        _pickedMarker = Marker(
          markerId: const MarkerId('picked'),
          position: LatLng(lat, lng),
        );
      });
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _latCtrl.text = position.latitude.toStringAsFixed(6);
      _lngCtrl.text = position.longitude.toStringAsFixed(6);
      _pickedMarker = Marker(
        markerId: const MarkerId('picked'),
        position: position,
      );
    });
  }

  Future<void> _detectLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      _onMapTap(latLng);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
    } else if (mounted) {
      AppHelpers.showSnackBar(context, 'Could not detect location. Check permissions.', isError: true);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final listings = context.read<ListingsProvider>();
    final auth = context.read<AppAuthProvider>();
    final user = auth.firebaseUser;
    if (user == null) return;

    final latitude = Validators.parseCoordinate(_latCtrl.text);
    final longitude = Validators.parseCoordinate(_lngCtrl.text);

    bool success;
    if (_isEditMode) {
      final updated = widget.existingListing!.copyWith(
        name: _nameCtrl.text.trim(),
        category: _selectedCategory.name,
        address: _addressCtrl.text.trim(),
        contact: _contactCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        latitude: latitude,
        longitude: longitude,
      );
      success = await listings.updateListing(updated);
    } else {
      success = await listings.createListing(
        name: _nameCtrl.text.trim(),
        category: _selectedCategory.name,
        address: _addressCtrl.text.trim(),
        contact: _contactCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        latitude: latitude,
        longitude: longitude,
        createdBy: user.uid,
        createdByName: auth.userModel?.displayName ?? user.displayName ?? 'Unknown',
      );
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      AppHelpers.showSnackBar(context, _isEditMode ? 'Listing updated!' : 'Listing added!');
    } else {
      AppHelpers.showSnackBar(context, listings.errorMessage ?? AppStrings.genericError, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ListingsProvider>().isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditMode ? AppStrings.editListing : AppStrings.addListing),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionLabel('Place / Service Name'),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'e.g. King Faisal Hospital', prefixIcon: Icon(Icons.place_outlined)),
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: AppSpacing.md),

              const _SectionLabel('Category'),
              DropdownButtonFormField<AppCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
                items: AppCategory.values.map((cat) {
                  final info = kCategoryMeta[cat]!;
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(children: [Icon(info.iconData, size: 18, color: info.color), const SizedBox(width: AppSpacing.sm), Text(info.label)]),
                  );
                }).toList(),
                onChanged: (v) => v != null ? setState(() => _selectedCategory = v) : null,
              ),
              const SizedBox(height: AppSpacing.md),

              const _SectionLabel('Location Picker'),
              Text('Tap the map to set location or detect your current spot.', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                child: SizedBox(
                  height: 250,
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _pickedMarker?.position ?? _kigaliCenter,
                          zoom: _pickedMarker != null ? 15 : 12,
                        ),
                        onMapCreated: (c) => _mapController = c,
                        onTap: _onMapTap,
                        markers: _pickedMarker != null ? {_pickedMarker!} : {},
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                      ),
                      PositionAction(icon: Icons.my_location, onTap: _detectLocation),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              const _SectionLabel('Geographic Coordinates'),
              TextFormField(
                controller: _latCtrl,
                decoration: const InputDecoration(labelText: 'Latitude', prefixIcon: Icon(Icons.straighten_outlined)),
                validator: (v) => Validators.coordinates(v, 'Latitude'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _lngCtrl,
                decoration: const InputDecoration(labelText: 'Longitude', prefixIcon: Icon(Icons.straighten_outlined)),
                validator: (v) => Validators.coordinates(v, 'Longitude'),
              ),
              const SizedBox(height: AppSpacing.md),

              const _SectionLabel('Address'),
              TextFormField(
                controller: _addressCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'e.g. KG 544 St, Kacyiru, Kigali', prefixIcon: Icon(Icons.location_on_outlined)),
                validator: (v) => Validators.required(v, 'Address'),
              ),
              const SizedBox(height: AppSpacing.md),

              const _SectionLabel('Contact & Description'),
              TextFormField(
                controller: _contactCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'e.g. +250 788 000 000', prefixIcon: Icon(Icons.phone_outlined)),
                validator: Validators.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Describe the place...', prefixIcon: Icon(Icons.notes_outlined)),
                validator: (v) => Validators.required(v, 'Description'),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(_isEditMode ? Icons.save_outlined : Icons.add),
                  label: Text(_isEditMode ? 'Save Changes' : AppStrings.addListing),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class PositionAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const PositionAction({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 12,
      child: FloatingActionButton.small(
        heroTag: null,
        onPressed: onTap,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        child: Icon(icon),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary)),
    );
  }
}
