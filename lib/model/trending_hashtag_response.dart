class trending_hashtag_response {
  String hashtags = '';
  String count = '';

  String category = '';

  trending_hashtag_response(this.hashtags, this.count, this.category);

  Map<String, dynamic> toJson() => {
        'hashtags': hashtags,
        'count': count,
        'category': category,
      };
}
