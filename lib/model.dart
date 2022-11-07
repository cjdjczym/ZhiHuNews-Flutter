/// 模型类我就不用 QuickType 了，这里解析一些用得到的数据吧

/// 每一天的所有新闻，只有当天有[topStories]，其余的[topStories]均为空
class Daily {
  final String date;
  final List<Story> topStories;
  final List<Story> stories;

  Daily.fromJson(Map<String, dynamic> json)
      : this.date = json['date'],
        this.topStories =
        (json['top_stories'] == null) ? [] :
            List<Story>.from(json['top_stories'].map((x) => Story.fromJson(x))),
        this.stories =
            List<Story>.from(json['stories'].map((x) => Story.fromJson(x)));
}

/// 单个故事的模型类
class Story {
  final String title;
  final String url;
  final String hint;
  final String image;

  Story.fromJson(Map<String, dynamic> json)
      : this.title = json['title'],
        this.url = json['url'],
        this.hint = json['hint'],
        // 这里需要做个判断，[top_stories]中的字段为`image`，而[stories]中的字段为`images`
        this.image = (json['images'] == null) ? json['image'] :
          List<String>.from(json["images"]).first;
}
