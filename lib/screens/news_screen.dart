import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/cricket_data_service.dart';
import '../theme/app_colors.dart';

class NewsScreen extends StatefulWidget {
  final CricketDataService dataService;

  const NewsScreen({
    super.key,
    required this.dataService,
  });

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final newsList = widget.dataService.cricketNews;
    final filteredNews = _selectedCategory == 'All'
        ? newsList
        : newsList.where((n) => n.category.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('CRICKET NEWS & INSIGHTS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All'),
                _buildCategoryChip('World Cup'),
                _buildCategoryChip('Analysis'),
                _buildCategoryChip('IPL'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // News Articles
          ...filteredNews.map((article) => _buildArticleCard(article)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedCategory = label;
            });
          }
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildArticleCard(CricketNews article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image or Banner
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'By ${article.author}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${article.timeAgo} • ${article.readTime}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article.summary,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Footer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.favorite_border, size: 18, color: AppColors.liveRed),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Liked article!')),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${article.likes}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              article.isBookmarked = !article.isBookmarked;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.textSecondary),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Article link copied!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
