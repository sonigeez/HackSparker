import 'dart:developer';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/story.dart';
import '../services/story_service.dart';

class StoryBloc {
  final StoryService _storyService = StoryService();
  final PagingController<int, Story> _pagingController =
      PagingController(firstPageKey: 0);
  late List<int> _topStories;

  StoryBloc() {
    init();
  }

  Future<void> init() async {
    _topStories = await _storyService.fetchTopStories();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    log('pageKey: $pageKey');
    try {
      final List<Story> fetchedStories = [];

      int endIndex =
          pageKey + 1 < _topStories.length ? pageKey + 1 : _topStories.length;

      List<Future<Story>> storyFutures = [];
      for (int i = pageKey; i < endIndex; i++) {
        storyFutures.add(_storyService.fetchStory(_topStories[i]));
      }

      fetchedStories.addAll(await Future.wait(storyFutures));

      final bool isLastPage = endIndex >= _topStories.length;

      if (isLastPage) {
        _pagingController.appendLastPage(fetchedStories);
      } else {
        final int nextPageKey = endIndex;
        _pagingController.appendPage(fetchedStories, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  PagingController<int, Story> get pagingController => _pagingController;
}
