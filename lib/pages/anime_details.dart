import 'package:flutter/material.dart';
import 'package:miru/enums/app_bar_type.dart';
import 'package:miru/widgets/custom_app_bar.dart';

class AnimeDetailsPage extends StatefulWidget {
  const AnimeDetailsPage({Key? key}) : super(key: key);
  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        appBarType: AppBarType.back,
      ),
      body: Text('Anime details here'),
    );
  }
}
