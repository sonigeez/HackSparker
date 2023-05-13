part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final List<dynamic> stories;

  const HomeLoadedState(this.stories);

  @override
  List<Object> get props => [stories];
}

class HomeEmptyState extends HomeState {}

class HomeErrorState extends HomeState {
  final String errorMessage;

  const HomeErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class HomeRefreshingState extends HomeState {}

class HomePaginationLoadingState extends HomeState {}

class HomePaginationLoadedState extends HomeState {
  final List<Story> paginatedStory;

  const HomePaginationLoadedState(this.paginatedStory);

  @override
  List<Object> get props => [paginatedStory];
}

class HomePaginationEndReachedState extends HomeState {}

class HomePaginationErrorState extends HomeState {
  final String errorMessage;

  const HomePaginationErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
