import 'package:flutter_infinite_list_bloc/data/data_provider/post_data_provider.dart';
import 'package:flutter_infinite_list_bloc/data/models/post.dart';

class PostRepository {
  final PostDataProvider postDataProvider;

  PostRepository(this.postDataProvider);

  Future<List<Post>> fetchPosts({int startIndex = 0, int limit}) =>
      postDataProvider.fetchPosts(startIndex, limit);
}
