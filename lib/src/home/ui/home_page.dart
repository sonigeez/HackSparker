import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hacksparker/src/home/bloc/home_bloc.dart';
import 'package:hacksparker/src/home/models/story.dart';
import 'package:hacksparker/src/home/ui/widgets/shimmer_loading.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  PagingController<int, Story> pagingController =
      PagingController(firstPageKey: 0);
  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = context.read<HomeBloc>();
    _homeBloc.add(FetchAllStoriesEvent());
    pagingController.addPageRequestListener((pageKey) {
      _homeBloc.add(FetchPageEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hacker News Top Stories')),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          // TODO: implement listener
          log("state is ${state.toString()}");
          if (state is HomeInitialState) {
            context.read<HomeBloc>().add(FetchAllStoriesEvent());
          }
          if (state is HomeLoadedState) {
            _homeBloc.add(FetchPageEvent());
          }
          if (state is HomePaginationLoadedState) {
            pagingController.appendPage(
              state.paginatedStory,
              _homeBloc.currentPage,
            );
          }
        },
        builder: (context, state) {
          if (state is HomeInitialState || state is HomeLoadingState) {
            return const ShimmerLoading();
          }
          if (state is HomeErrorState) {
            return Center(child: Text(state.errorMessage));
          }
          return PagedListView<int, Story>(
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate<Story>(
              newPageProgressIndicatorBuilder: (context) {
                return const ShimmerLoading();
              },
              firstPageProgressIndicatorBuilder: (context) {
                return const ShimmerLoading();
              },
              itemBuilder: (context, item, index) => ListTile(
                title: Text(item.title),
                leading: CachedNetworkImage(
                  width: 50,
                  imageUrl: item.ogImage ??
                      "https://cdn.dribbble.com/users/3093/screenshots/797096/hn-logo-dribbble-shot.png",
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
