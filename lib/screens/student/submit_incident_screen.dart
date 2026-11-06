
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/incident_provider.dart';
import '../../services/cloudinary_service.dart';

class SubmitIncidentScreen extends StatefulWidget {
  const SubmitIncidentScreen({super.key});

  @override
  State<SubmitIncidentScreen> createState() =>
      _SubmitIncidentScreenState();
}

class _SubmitIncidentScreenState
    extends State<SubmitIncidentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService =
      CloudinaryService();

  String? _selectedCategory;
  XFile? _selectedImage;

  final List<String> _categories = [
    'Theft',
    'Harassment',
    'Safety Concern',
    'Infrastructure',
    'Medical Emergency',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      debugPrint('Image picker error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final incidentProvider =
        context.read<IncidentProvider>();

    String? photoUrl;

    try {
      if (_selectedImage != null) {
        photoUrl = await _cloudinaryService.uploadImage(
          _selectedImage!,
        );
      }

      final success =
          await incidentProvider.submitIncident(
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        location: _locationController.text.trim(),
        photoUrl: photoUrl,
      );

      if (!mounted) return;

      if (success) {
        _descriptionController.clear();
        _locationController.clear();

        setState(() {
          _selectedCategory = null;
          _selectedImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Incident reported successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              incidentProvider.errorMessage ??
                  'Something went wrong.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Incident'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Help us keep your campus safe.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),

                _buildLabel('What happened?'),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Describe the incident...',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.indigo.withValues(
                      alpha: 0.03,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please describe the incident.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildLabel('Category'),

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    hintText: 'Select a category',
                    filled: true,
                    fillColor: Colors.indigo.withValues(
                      alpha: 0.03,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildLabel('Location'),

                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Where did it happen?',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                    ),
                    filled: true,
                    fillColor: Colors.indigo.withValues(
                      alpha: 0.03,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter the location.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                _buildLabel('Photo attachment (optional)'),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(
                      alpha: 0.04,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_selectedImage != null)
                        Text(
                          'Selected: ${_selectedImage!.name}',
                          textAlign: TextAlign.center,
                        )
                      else
                        const Icon(
                          Icons.add_a_photo_outlined,
                          size: 32,
                          color: Colors.indigo,
                        ),

                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(
                          Icons.photo_library_outlined,
                        ),
                        label: const Text('Choose Photo'),
                      ),

                      if (_selectedImage != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: const Text('Remove Photo'),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Consumer<IncidentProvider>(
                  builder: (context, provider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: provider.isLoading
                            ? null
                            : _submitReport,
                        icon: provider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          provider.isLoading
                              ? 'Submitting...'
                              : 'Submit Report',
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
