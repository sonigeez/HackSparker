import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hacksparker/src/home/bloc/home_bloc.dart';
import 'package:hacksparker/src/home/models/story.dart';
import 'package:hacksparker/src/home/ui/widgets/shimmer_loading.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final StoryBloc _storyBloc = StoryBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hacker News Top Stories')),
      body: FutureBuilder(
        future: _storyBloc.init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PagedListView<int, Story>(
              pagingController: _storyBloc.pagingController,
              builderDelegate: PagedChildBuilderDelegate<Story>(
                itemBuilder: (context, story, index) => ListTile(
                  leading: CachedNetworkImage(
                      imageUrl:
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Y_Combinator_logo.svg/640px-Y_Combinator_logo.svg.png"),
                  title: Text(story.title),
                  subtitle: Text('Score: ${story.score}'),
                  onTap: () {
                    // Handle on-tap to open the story URL, for example, using the url_launcher package
                  },
                ),
                firstPageErrorIndicatorBuilder: (context) => const Center(
                  child: Text('Failed to load top stories. Please try again.'),
                ),
                newPageErrorIndicatorBuilder: (context) => const Center(
                  child: Text('Failed to load more stories. Please try again.'),
                ),
                firstPageProgressIndicatorBuilder: (context) => const Center(
                  child: ShimmerLoading(),
                ),
                newPageProgressIndicatorBuilder: (context) => const Center(
                  child: ShimmerLoading(),
                ),
                noItemsFoundIndicatorBuilder: (context) => const Center(
                  child: Text('No stories found.'),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _storyBloc.pagingController.dispose();
    super.dispose();
  }
}
