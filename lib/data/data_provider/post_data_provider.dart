import 'package:flutter_infinite_list_bloc/data/models/post.dart';
import 'package:http/http.dart' as http;

class PostDataProvider {
  final http.Client httpClient;

  PostDataProvider({this.httpClient});

  Future<List<Post>> fetchPosts(int startIndex, int limit) async {
    final response = await httpClient.get(
        'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
    if (response.statusCode == 200) {
      final data = postFromJson(response.body);
      return data;
    } else {
      throw Exception('error fetching posts');
    }
  }
}
