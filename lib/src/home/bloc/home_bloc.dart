import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hacksparker/src/home/models/story.dart';
import 'package:hacksparker/src/home/services/story_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final StoryService storyService;
  final List<int> storyIds = [];
  // A counter to keep track of the current page
  int currentPage = 0;
  final itemsPerPage = 3;

  HomeBloc({required this.storyService}) : super(HomeInitialState()) {
    // Registering event handlers
    on<FetchAllStoriesEvent>(fetchAllStoriesEvent);
    on<FetchPageEvent>(fetchPageEvent);
  }

  // Event handler for FetchAllStoriesEvent
  Future<void> fetchAllStoriesEvent(
      FetchAllStoriesEvent event, Emitter<HomeState> emit) async {
    try {
      storyIds.addAll(await storyService.fetchTopStories());
      emit(const HomeLoadedState([]));
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }

  // Event handler for FetchPageEvent
  Future<void> fetchPageEvent(
      FetchPageEvent event, Emitter<HomeState> emit) async {
    try {
      emit(HomePaginationLoadingState());
      final newItems = (await Future.wait(storyIds
              .skip(currentPage * itemsPerPage)
              .take(itemsPerPage)
              .map((id) async {
        try {
          return await storyService.fetchStory(id);
        } catch (e) {
          // You can print the error or handle it in some other way here
          print(e);
          return null; // Return null or some default value
        }
      })))
          .where((item) => item != null) // Filter out null values
          .cast<Story>() // Cast to List<Story>
          .toList(); // Convert to list again

      currentPage++;
      emit(HomePaginationLoadedState(newItems));
    } catch (e) {
      emit(HomePaginationErrorState(e.toString()));
    }
  }
}
