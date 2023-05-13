part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchAllStoriesEvent extends HomeEvent {}

class FetchStoryEvent extends HomeEvent {
  final int storyId;

  const FetchStoryEvent(this.storyId);

  @override
  List<Object> get props => [storyId];
}

class FetchPageEvent extends HomeEvent {}
