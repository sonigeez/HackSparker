class Story {
  final int id;
  final String title;
  final String url;
  final int score;
  String? description;
  String? ogImage;

  Story({
    required this.id,
    required this.title,
    required this.url,
    required this.score,
    this.description,
    this.ogImage,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      score: json['score'],
    );
  }
}
