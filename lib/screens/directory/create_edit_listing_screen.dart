import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';

class CreateEditListingScreen extends StatefulWidget {
  // Pass an existing listing to enter edit mode
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

  bool get _isEditMode => widget.existingListing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existingListing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _addressCtrl = TextEditingController(text: e?.address ?? '');
    _contactCtrl = TextEditingController(text: e?.contact ?? '');
    _descriptionCtrl = TextEditingController(text: e?.description ?? '');
    _latCtrl = TextEditingController(
      text: e != null ? e.latitude.toString() : '',
    );
    _lngCtrl = TextEditingController(
      text: e != null ? e.longitude.toString() : '',
    );
    _selectedCategory =
        e != null ? e.categoryEnum : AppCategory.other;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _descriptionCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final listings = context.read<ListingsProvider>();
    final auth = context.read<AppAuthProvider>();
    final user = auth.firebaseUser;
    if (user == null) return;

    bool success;

    if (_isEditMode) {
      final updated = widget.existingListing!.copyWith(
        name: _nameCtrl.text.trim(),
        category: _selectedCategory.name,
        address: _addressCtrl.text.trim(),
        contact: _contactCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        latitude: double.parse(_latCtrl.text.trim()),
        longitude: double.parse(_lngCtrl.text.trim()),
        timestamp: DateTime.now(),
      );
      success = await listings.updateListing(updated);
    } else {
      success = await listings.createListing(
        name: _nameCtrl.text.trim(),
        category: _selectedCategory.name,
        address: _addressCtrl.text.trim(),
        contact: _contactCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        latitude: double.parse(_latCtrl.text.trim()),
        longitude: double.parse(_lngCtrl.text.trim()),
        createdBy: user.uid,
        createdByName:
            auth.userModel?.displayName ?? user.displayName ?? 'Unknown',
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      AppHelpers.showSnackBar(
        context,
        _isEditMode
            ? 'Listing updated successfully!'
            : 'Listing added successfully!',
      );
    } else {
      AppHelpers.showSnackBar(
        context,
        listings.errorMessage ?? AppStrings.genericError,
        isError: true,
      );
    }
  }

  Future<void> _deleteListing() async {
    final confirmed = await AppHelpers.showConfirmDialog(
      context,
      title: AppStrings.deleteListing,
      message:
          'Are you sure you want to delete "${widget.existingListing!.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    final success = await context
        .read<ListingsProvider>()
        .deleteListing(widget.existingListing!.id);

    if (!mounted) return;
    if (success) {
      // Pop both the edit screen and the detail screen
      Navigator.pop(context);
      Navigator.pop(context);
      AppHelpers.showSnackBar(context, 'Listing deleted.');
    } else {
      AppHelpers.showSnackBar(
        context,
        context.read<ListingsProvider>().errorMessage ??
            AppStrings.genericError,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ListingsProvider>().isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
            _isEditMode ? AppStrings.editListing : AppStrings.addListing),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: AppStrings.deleteListing,
              onPressed: isLoading ? null : _deleteListing,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // place name
              _SectionLabel('Place / Service Name'),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'e.g. King Faisal Hospital',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: AppSpacing.md),

              // category
              _SectionLabel('Category'),
              DropdownButtonFormField<AppCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppCategory.values.map((cat) {
                  final info = kCategoryMeta[cat]!;
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(info.iconData, size: 18, color: info.color),
                        const SizedBox(width: AppSpacing.sm),
                        Text(info.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // address
              _SectionLabel('Address'),
              TextFormField(
                controller: _addressCtrl,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'e.g. KG 544 St, Kacyiru, Kigali',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => Validators.required(v, 'Address'),
              ),
              const SizedBox(height: AppSpacing.md),

              // contact number
              _SectionLabel('Contact Number (optional)'),
              TextFormField(
                controller: _contactCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'e.g. +250 788 000 000',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: Validators.phone,
              ),
              const SizedBox(height: AppSpacing.md),

              // description
              _SectionLabel('Description'),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText:
                      'Describe the place — services offered, opening hours, etc.',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (v) => Validators.required(v, 'Description'),
              ),
              const SizedBox(height: AppSpacing.md),

              // coordinates
              _SectionLabel('Geographic Coordinates'),
              Text(
                'Open Google Maps, long-press your location, and copy the coordinates shown.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: '-1.9441',
                        prefixIcon: Icon(Icons.straighten_outlined),
                      ),
                      validator: (v) =>
                          Validators.coordinates(v, 'Latitude'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: '30.0619',
                        prefixIcon: Icon(Icons.straighten_outlined),
                      ),
                      validator: (v) =>
                          Validators.coordinates(v, 'Longitude'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // submit button
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(
                          _isEditMode ? Icons.save_outlined : Icons.add,
                        ),
                  label: Text(
                    _isEditMode ? 'Save Changes' : AppStrings.addListing,
                  ),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}