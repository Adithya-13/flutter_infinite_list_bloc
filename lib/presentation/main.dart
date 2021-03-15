import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list_bloc/business_logic/blocs/post_bloc.dart';
import 'package:flutter_infinite_list_bloc/business_logic/blocs/simple_bloc_observer.dart';
import 'package:flutter_infinite_list_bloc/data/data_provider/post_data_provider.dart';
import 'package:flutter_infinite_list_bloc/data/models/post.dart';
import 'package:flutter_infinite_list_bloc/data/repositories/post_repository.dart';
import 'package:http/http.dart' as http;

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final PostRepository postRepository =
      PostRepository(PostDataProvider(httpClient: http.Client()));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Infinite Scroll',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Posts'),
        ),
        body: BlocProvider(
          create: (context) =>
              PostBloc(postRepository: postRepository)..add(PostFetched()),
          child: HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postBloc = context.read<PostBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        switch (state.status) {
          case PostStatus.failure:
            return const Center(child: Text('failed to fetch posts'));
          case PostStatus.success:
            if (state.posts.isEmpty) {
              return const Center(child: Text('no posts'));
            }
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.posts.length
                    ? BottomLoader()
                    : PostWidget(post: state.posts[index]);
              },
              itemCount: state.hasReachedMax
                  ? state.posts.length
                  : state.posts.length + 1,
              controller: _scrollController,
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) _postBloc.add(PostFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '${post.id}',
        style: TextStyle(fontSize: 10.0),
      ),
      title: Text(post.title),
      isThreeLine: true,
      subtitle: Text(post.body),
      dense: true,
    );
  }
}
