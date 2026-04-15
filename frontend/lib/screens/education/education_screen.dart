/// Education Screen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../models/medication_reminder.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});
  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final _api = ApiService();
  List<EducationArticle> _articles = [];
  bool _isLoading = true;
  String? _selectedCategory;

  final _categoryIcons = {
    'diabetes': Icons.bloodtype,
    'heart_disease': Icons.favorite,
    'hypertension': Icons.speed,
    'asthma': Icons.air,
    'mental_health': Icons.psychology,
    'nutrition': Icons.restaurant,
    'exercise': Icons.fitness_center,
    'preventive_care': Icons.shield,
    'general': Icons.health_and_safety,
  };

  final _categoryColors = {
    'diabetes': const Color(0xFFE91E63),
    'heart_disease': const Color(0xFFEF5350),
    'hypertension': const Color(0xFFFF9800),
    'asthma': const Color(0xFF4CAF50),
    'mental_health': const Color(0xFF7C4DFF),
    'nutrition': const Color(0xFF26A69A),
    'exercise': const Color(0xFF42A5F5),
    'preventive_care': const Color(0xFF66BB6A),
    'general': const Color(0xFF78909C),
  };

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    setState(() => _isLoading = true);
    final params = <String, dynamic>{};
    if (_selectedCategory != null) params['category'] = _selectedCategory;

    final response = await _api.get(ApiConfig.education, queryParams: params);
    if (response.isSuccess && mounted) {
      final list = response.data['data']['articles'] as List;
      _articles = list.map((e) => EducationArticle.fromJson(e)).toList();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Education')),
      body: Column(
        children: [
          // Category filter
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip('All', null, Icons.apps, AppTheme.primaryColor),
                ..._categoryIcons.entries.map((e) => _CategoryChip(
                  e.key.replaceAll('_', ' ').split(' ').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' '),
                  e.key, e.value, _categoryColors[e.key] ?? AppTheme.primaryColor,
                )),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _articles.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book, size: 64, color: AppTheme.lightText),
                      const SizedBox(height: 16),
                      Text('No articles found', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _articles.length,
                    itemBuilder: (context, index) {
                      final article = _articles[index];
                      final color = _categoryColors[article.category] ?? AppTheme.primaryColor;
                      return GestureDetector(
                        onTap: () => context.push('/education/${article.slug}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: AppTheme.cardDecoration(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Color bar
                              Container(
                                width: double.infinity, height: 4,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                          child: Text(article.categoryDisplay, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                                        ),
                                        const Spacer(),
                                        Icon(Icons.access_time, size: 14, color: AppTheme.lightText),
                                        const SizedBox(width: 4),
                                        Text('${article.readingTimeMinutes} min', style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(article.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, height: 1.3)),
                                    const SizedBox(height: 8),
                                    Text(article.summary, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        CircleAvatar(radius: 12, backgroundColor: color.withOpacity(0.1), child: Icon(Icons.person, size: 14, color: color)),
                                        const SizedBox(width: 8),
                                        Text(article.authorName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                        const Spacer(),
                                        Icon(Icons.visibility, size: 14, color: AppTheme.lightText),
                                        const SizedBox(width: 4),
                                        Text('${article.views}', style: Theme.of(context).textTheme.bodySmall),
                                        const SizedBox(width: 12),
                                        Icon(Icons.favorite, size: 14, color: AppTheme.lightText),
                                        const SizedBox(width: 4),
                                        Text('${article.likes}', style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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

  Widget _CategoryChip(String label, String? category, IconData icon, Color color) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() => _selectedCategory = category);
          _fetchArticles();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : AppTheme.borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: isSelected ? color : AppTheme.lightText),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? color : AppTheme.mediumText)),
            ],
          ),
        ),
      ),
    );
  }
}
