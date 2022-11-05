import 'package:objectbox/objectbox.dart';

@Entity()
class EntityAnime {
  @Id()
  int id = 0;

  @Index()
  int? animeId;

  String? title;

  EntityAnime(this.id, this.animeId, this.title);
}
