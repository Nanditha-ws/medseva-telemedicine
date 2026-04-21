/// Hospital Finder Screen
library;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../models/user.dart';

class HospitalFinderScreen extends StatefulWidget {
  const HospitalFinderScreen({super.key});
  @override
  State<HospitalFinderScreen> createState() => _HospitalFinderScreenState();
}

class _HospitalFinderScreenState extends State<HospitalFinderScreen> {
  final _api = ApiService();
  final _searchController = TextEditingController();
  List<HospitalProfile> _hospitals = [];
  bool _isLoading = true;
  bool _emergencyOnly = false;
  bool _ambulanceOnly = false;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    setState(() => _isLoading = true);
    final params = <String, dynamic>{};
    if (_searchController.text.isNotEmpty) params['search'] = _searchController.text;
    if (_emergencyOnly) params['emergency'] = 'true';
    if (_ambulanceOnly) params['ambulance'] = 'true';
    if (_selectedType != null) params['type'] = _selectedType;

    final response = await _api.get(ApiConfig.hospitals, queryParams: params);
    if (response.isSuccess && mounted) {
      final list = response.data['data']['hospitals'] as List;
      _hospitals = list.map((e) => HospitalProfile.fromJson(e)).toList();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Hospital')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _fetchHospitals(),
              decoration: InputDecoration(
                hintText: 'Search hospitals, clinics...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilters),
              ),
            ),
          ),

          // Quick filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _QuickFilter('Emergency', Icons.emergency, _emergencyOnly, () {
                  setState(() => _emergencyOnly = !_emergencyOnly);
                  _fetchHospitals();
                }),
                const SizedBox(width: 8),
                _QuickFilter('Ambulance', Icons.local_shipping, _ambulanceOnly, () {
                  setState(() => _ambulanceOnly = !_ambulanceOnly);
                  _fetchHospitals();
                }),
                const SizedBox(width: 8),
                _TypeFilter('Hospital', 'hospital'),
                _TypeFilter('Clinic', 'clinic'),
                _TypeFilter('Pharmacy', 'pharmacy'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Results
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hospitals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_hospital_outlined, size: 64, color: AppTheme.lightText),
                        const SizedBox(height: 16),
                        Text('No hospitals found', style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _hospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = _hospitals[index];
                      return GestureDetector(
                        onTap: () => context.push('/hospitals/${hospital.id}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.cardDecoration(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50, height: 50,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGreen.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      hospital.type == 'clinic' ? Icons.medical_services : Icons.local_hospital,
                                      color: AppTheme.accentGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(hospital.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                        Text('${hospital.city}, ${hospital.state}', style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  if (hospital.rating > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentOrange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.star, size: 14, color: AppTheme.accentOrange),
                                          const SizedBox(width: 4),
                                          Text('${hospital.rating}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.accentOrange)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: AppTheme.lightText),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(hospital.address, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (hospital.emergencyServices)
                                    _Badge('Emergency', AppTheme.accentRed),
                                  if (hospital.ambulanceAvailable)
                                    _Badge('Ambulance', AppTheme.accentBlue),
                                  if (hospital.distance != null)
                                    _Badge('${hospital.distance!.toStringAsFixed(1)} km', AppTheme.accentGreen),
                                ],
                              ),
                              if (hospital.specializations.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6, runSpacing: 4,
                                  children: hospital.specializations.take(4).map((s) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(s, style: TextStyle(fontSize: 10, color: AppTheme.primaryColor)),
                                  )).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _Badge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _QuickFilter(String label, IconData icon, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentRed.withOpacity(0.1) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppTheme.accentRed : AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? AppTheme.accentRed : AppTheme.lightText),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? AppTheme.accentRed : AppTheme.mediumText)),
          ],
        ),
      ),
    );
  }

  Widget _TypeFilter(String label, String type) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedType = isSelected ? null : type);
          _fetchHospitals();
        },
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            SwitchListTile(title: const Text('Emergency Services'), value: _emergencyOnly,
              onChanged: (v) { setState(() => _emergencyOnly = v); Navigator.pop(ctx); _fetchHospitals(); }),
            SwitchListTile(title: const Text('Ambulance Available'), value: _ambulanceOnly,
              onChanged: (v) { setState(() => _ambulanceOnly = v); Navigator.pop(ctx); _fetchHospitals(); }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
