import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hacksparker/src/home/models/story.dart';
import 'package:hacksparker/src/home/services/story_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final StoryService storyService;
  final List<int> storyIds = [];
  int currentPage = 0;
  final itemsPerPage = 1; // Set this to your desired page size

  HomeBloc({required this.storyService}) : super(HomeInitialState()) {
    on<FetchAllStoriesEvent>(fetchAllStoriesEvent);
    on<FetchPageEvent>(fetchPageEvent);
  }

  Future<void> fetchAllStoriesEvent(
      FetchAllStoriesEvent event, Emitter<HomeState> emit) async {
    try {
      storyIds.addAll(await storyService.fetchTopStories());
      emit(const HomeLoadedState([]));
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }

  Future<void> fetchPageEvent(
      FetchPageEvent event, Emitter<HomeState> emit) async {
    try {
      emit(HomePaginationLoadingState());
      final newItems = await Future.wait(storyIds
          .skip(currentPage * itemsPerPage)
          .take(itemsPerPage)
          .map((id) => storyService.fetchStory(id)));

      currentPage++;
      emit(HomePaginationLoadedState(newItems));
    } catch (e) {
      emit(HomePaginationErrorState(e.toString()));
    }
  }
}
