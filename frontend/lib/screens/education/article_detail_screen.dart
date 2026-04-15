/// Article Detail Screen
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../models/medication_reminder.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String slug;
  const ArticleDetailScreen({super.key, required this.slug});
  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  EducationArticle? _article;
  bool _isLoading = true;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _fetchArticle();
  }

  Future<void> _fetchArticle() async {
    final response = await ApiService().get('${ApiConfig.education}/${widget.slug}');
    if (response.isSuccess && mounted) {
      setState(() {
        _article = EducationArticle.fromJson(response.data['data']['article']);
        _isLoading = false;
      });
    }
  }

  Future<void> _likeArticle() async {
    if (_article == null || _isLiked) return;
    await ApiService().post('${ApiConfig.education}/${_article!.id}/like');
    setState(() => _isLiked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    final article = _article!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          IconButton(
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? AppTheme.accentRed : null),
            onPressed: _likeArticle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(article.categoryDisplay, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            Text(article.title, style: Theme.of(context).textTheme.headlineLarge?.copyWith(height: 1.3)),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person, size: 18, color: AppTheme.primaryColor)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.authorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (article.author?['credentials'] != null)
                      Text(article.author!['credentials'], style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: AppTheme.lightText),
                const SizedBox(width: 4),
                Text('${article.readingTimeMinutes} min read', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Render content (markdown-like simple rendering)
            ..._renderContent(article.content ?? article.summary),

            const SizedBox(height: 24),
            // Tags
            if (article.tags.isNotEmpty)
              Wrap(
                spacing: 8, runSpacing: 8,
                children: article.tags.map((tag) => Chip(
                  label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            const SizedBox(height: 24),

            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    Icon(Icons.visibility, color: AppTheme.lightText),
                    const SizedBox(height: 4),
                    Text('${article.views}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Views', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                  Column(children: [
                    Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? AppTheme.accentRed : AppTheme.lightText),
                    const SizedBox(height: 4),
                    Text('${article.likes + (_isLiked ? 1 : 0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Likes', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                  Column(children: [
                    Icon(Icons.share, color: AppTheme.lightText),
                    const SizedBox(height: 4),
                    const Text('Share', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('Article', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderContent(String content) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(line.substring(2), style: Theme.of(context).textTheme.headlineMedium),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(line.substring(3), style: Theme.of(context).textTheme.titleLarge),
        ));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 6, height: 6,
                decoration: BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(line.substring(2), style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6))),
            ],
          ),
        ));
      } else if (RegExp(r'^\d+\.').hasMatch(line)) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(line, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(line.replaceAll('**', ''), style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
        ));
      }
    }
    return widgets;
  }
}
