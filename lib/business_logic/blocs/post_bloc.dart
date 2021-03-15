import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_infinite_list_bloc/data/models/post.dart';
import 'package:flutter_infinite_list_bloc/data/repositories/post_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'post_event.dart';

part 'post_state.dart';

const _postLimit = 20;

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;

  PostBloc({@required this.postRepository}) : super(PostState());

  @override
  Stream<Transition<PostEvent, PostState>> transformEvents(
    Stream<PostEvent> events,
    TransitionFunction<PostEvent, PostState> transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    if (event is PostFetched) {
      yield await _mapPostFetchedToState(state);
    }
  }

  Future<PostState> _mapPostFetchedToState(PostState state) async {
    if (state.hasReachedMax) return state;
    try {
      if (state.status == PostStatus.initial) {
        final posts = await postRepository.fetchPosts(limit: _postLimit);
        return state.copyWith(
          status: PostStatus.success,
          posts: posts,
          hasReachedMax: _hasReachedMax(posts.length),
        );
      }
      final posts = await postRepository.fetchPosts(
          startIndex: state.posts.length, limit: _postLimit);
      return posts.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: PostStatus.success,
              posts: List.of(state.posts)..addAll(posts),
              hasReachedMax: _hasReachedMax(posts.length),
            );
    } on Exception {
      return state.copyWith(status: PostStatus.failure);
    }
  }

  bool _hasReachedMax(int postsCount) =>
      postsCount <= _postLimit ? false : true;
}
