/// Document Scanner Screen
library;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../widgets/custom_button.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _api = ApiService();
  final _picker = ImagePicker();
  File? _selectedImage;
  Map<String, dynamic>? _scanResult;
  bool _isProcessing = false;
  String _documentType = 'prescription';
  final _titleController = TextEditingController();

  final _docTypes = {
    'prescription': 'Prescription',
    'lab_report': 'Lab Report',
    'medical_bill': 'Medical Bill',
    'insurance_card': 'Insurance Card',
    'id_card': 'ID Card',
    'other': 'Other',
  };

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 2000, maxHeight: 2000, imageQuality: 90);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _scanResult = null;
      });
    }
  }

  Future<void> _scanDocument() async {
    if (_selectedImage == null) return;
    setState(() => _isProcessing = true);

    final response = await _api.uploadFile(
      ApiConfig.documentScan,
      _selectedImage!,
      fieldName: 'image',
      extraFields: {
        'title': _titleController.text.isNotEmpty ? _titleController.text : 'Scan_${DateTime.now().toIso8601String().substring(0, 10)}',
        'document_type': _documentType,
      },
    );

    if (response.isSuccess && mounted) {
      setState(() => _scanResult = response.data['data']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Document scanned successfully! ✓'), backgroundColor: AppTheme.accentGreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Scan failed'), backgroundColor: AppTheme.accentRed),
      );
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Scanner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.accentPurple, AppTheme.accentPurple.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI Document Scanner', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Scan prescriptions, reports & documents using edge detection and image enhancement',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Image selection area
            if (_selectedImage == null) ...[
              Container(
                width: double.infinity, height: 250,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor, width: 2, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_rounded, size: 56, color: AppTheme.lightText),
                    const SizedBox(height: 16),
                    Text('Select an image to scan', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Camera'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library, size: 18),
                          label: const Text('Gallery'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Preview selected image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_selectedImage!, width: double.infinity, height: 300, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: () => setState(() { _selectedImage = null; _scanResult = null; }),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(icon: const Icon(Icons.camera_alt, size: 18), label: const Text('Retake'), onPressed: () => _pickImage(ImageSource.camera)),
                  TextButton.icon(icon: const Icon(Icons.photo_library, size: 18), label: const Text('Choose Another'), onPressed: () => _pickImage(ImageSource.gallery)),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Document details
            if (_selectedImage != null) ...[
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Document Title', prefixIcon: Icon(Icons.title)),
              ),
              const SizedBox(height: 16),

              Text('Document Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _docTypes.entries.map((e) {
                  final isSelected = _documentType == e.key;
                  return ChoiceChip(
                    label: Text(e.value),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                    onSelected: (_) => setState(() => _documentType = e.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Scan & Process Document',
                isLoading: _isProcessing,
                onPressed: _scanDocument,
                isFullWidth: true,
                icon: Icons.document_scanner,
              ),
            ],

            // Scan results
            if (_scanResult != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.accentGreen),
                        const SizedBox(width: 8),
                        Text('Scan Complete!', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.accentGreen, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_scanResult!['processing'] != null) ...[
                      _ResultRow('Edge Detection', _scanResult!['processing']['edge_detection_method'] ?? 'N/A'),
                      _ResultRow('Perspective Corrected', _scanResult!['processing']['perspective_corrected'] == true ? 'Yes' : 'No'),
                      _ResultRow('Enhancement Applied', _scanResult!['processing']['enhancement_applied'] == true ? 'Yes' : 'No'),
                      _ResultRow('Processing Time', '${_scanResult!['processing']['processing_time_ms'] ?? 0}ms'),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _ResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.mediumText, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
