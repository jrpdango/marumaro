import 'package:flutter/material.dart';
import 'package:miru/enums/app_bar_type.dart';
import 'package:miru/widgets/custom_app_bar.dart';

class AnimeDetails extends StatefulWidget {
  const AnimeDetails({Key? key}) : super(key: key);
  @override
  State<AnimeDetails> createState() => _AnimeDetailsState();
}

class _AnimeDetailsState extends State<AnimeDetails> {
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
