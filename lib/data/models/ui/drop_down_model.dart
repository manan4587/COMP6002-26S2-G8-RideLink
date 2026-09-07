class DropDownModel {
  DropDownModel({this.id, this.title});
  factory DropDownModel.fromJson(Map<String, dynamic> json) =>
      DropDownModel(id: json['id'] as String?, title: json['title'] as String?);
  String? id;
  String? title;

  Map<String, dynamic> toJson() => {'id': id, 'title': title};

  @override
  bool operator ==(covariant DropDownModel other) {
    if (identical(this, other)) {
      return true;
    }

    return other.id == id && other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
