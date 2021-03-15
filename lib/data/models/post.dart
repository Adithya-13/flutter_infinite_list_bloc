import 'dart:convert';

import 'package:equatable/equatable.dart';

List<Post> postFromJson(String str) =>
    List<Post>.from(json.decode(str).map((x) => Post.fromJson(x)));

String postToJson(List<Post> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Post extends Equatable {
  final int id;
  final String title;
  final String body;

  Post({
    this.id,
    this.title,
    this.body,
  });

  Post copyWith({
    int id,
    String title,
    String body,
  }) =>
      Post(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
      );

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["id"],
        title: json["title"],
        body: json["body"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "body": body,
      };

  @override
  List<Object> get props => [id, title, body];

  @override
  String toString() => 'Post { id: $id }';
}
