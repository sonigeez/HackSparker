import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hacksparker/src/core/router/app_router.dart';
import 'package:hacksparker/src/core/services/network_requester.dart';
import 'package:hacksparker/src/home/bloc/home_bloc.dart';
import 'package:hacksparker/src/home/services/story_service.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => NetworkRequester(),
        ),
        RepositoryProvider(
          create: (context) => StoryService(
            requester: context.read<NetworkRequester>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeBloc(
              storyService: context.read<StoryService>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.orange,
          ),
          routerConfig: AppRouter.goRouter,
        ),
      ),
    );
  }
}
