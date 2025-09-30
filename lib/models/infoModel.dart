class Infomodel {
  int count;
  int pages;
  String next;
  String prev;

  Infomodel({
    required this.count,
    required this.pages,
    required this.next,
    required this.prev,
  });

  factory Infomodel.fromJson(Map<String, dynamic> json) {
    return Infomodel(
      count: json['count'],
      pages: json['pages'],
      next: json['next'] ?? '',
      prev: json['prev'] ?? '',
    );
  }
}