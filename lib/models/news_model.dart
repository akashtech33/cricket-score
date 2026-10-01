class CricketNews {
  final String id;
  final String title;
  final String summary;
  final String category; // 'Match Preview', 'Analysis', 'Trophy Watch', 'IPL News'
  final String timeAgo;
  final String readTime;
  final String author;
  final String imageUrl;
  final int likes;
  bool isBookmarked;

  CricketNews({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.timeAgo,
    required this.readTime,
    required this.author,
    required this.imageUrl,
    this.likes = 142,
    this.isBookmarked = false,
  });
}
