import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/enums.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_messages.dart';
import '../../utils/validators.dart';

class SubmitReportScreen extends ConsumerStatefulWidget {
  const SubmitReportScreen({super.key});
  @override
  ConsumerState<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends ConsumerState<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  IncidentCategory? _category;
  File? _image;

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final x = await ImagePicker()
        .pickImage(source: source, maxWidth: 1600, imageQuality: 80);
    if (x != null) setState(() => _image = File(x.path));
  }

  void _showPickerSheet() => showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
          child: Wrap(children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.gallery);
              },
            ),
          ]),
        ),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(incidentControllerProvider.notifier).submit(
          title: _title.text,
          description: _description.text,
          location: _location.text,
          category: _category!,
          image: _image,
        );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Report submitted. Thank you.')));
    } else {
      messenger.showSnackBar(SnackBar(
          content: Text(errorMessage(ref.read(incidentControllerProvider).error!))));
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loading = ref.watch(incidentControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('New report')),
      body: AbsorbPointer(
        absorbing: loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What is going on?', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('The more specific you are, the faster it gets fixed.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                const SizedBox(height: 24),
                _label('Category'),
                FormField<IncidentCategory>(
                  validator: (v) => v == null ? 'Select a category' : null,
                  builder: (state) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.15,
                        children: [
                          for (final c in IncidentCategory.values)
                            _CategoryTile(
                              category: c,
                              selected: _category == c,
                              onTap: () {
                                setState(() => _category = c);
                                state.didChange(c);
                              },
                            ),
                        ],
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(state.errorText!,
                              style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Title', hintText: 'e.g. No water on 2nd floor'),
                  validator: (v) => Validators.required(v, 'Title', min: 4),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _location,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'Building, floor or room',
                      prefixIcon: Icon(Icons.place_outlined)),
                  validator: (v) => Validators.required(v, 'Location'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _description,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Description', alignLabelWithHint: true),
                  validator: (v) => Validators.required(v, 'Description', min: 10),
                ),
                const SizedBox(height: 24),
                _label('Photo (optional)'),
                if (_image != null)
                  Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(_image!,
                          height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.black54, foregroundColor: Colors.white),
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _image = null),
                      ),
                    ),
                  ])
                else
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _showPickerSheet,
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                          SizedBox(height: 8),
                          Text('Tap to add a photo',
                              style: TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Submit report'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.selected, required this.onTap});
  final IncidentCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.ink;
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, color: selected ? Colors.white : AppColors.primary),
            const SizedBox(height: 6),
            Text(category.label,
                style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
