/// Cross-cutting building blocks shared across features: domain models, the
/// data/service layer, the theme, and the design-system widgets.
library;

export 'constants.dart';
export 'models/anime.dart';
export 'models/anime_details.dart';
export 'models/enums.dart';
export 'models/list_sort.dart';
export 'models/manga.dart';
export 'models/manga_details.dart';
export 'models/media_details_data.dart';
export 'models/page.dart';
export 'models/user.dart';
export 'models/user_list_status.dart';
export 'services/api_exception.dart';
export 'services/auth_repository.dart';
export 'services/global_controller.dart';
export 'services/local_store.dart';
export 'services/mal_api_client.dart';
export 'services/mal_repository.dart';
export 'services/pkce_code_gen.dart';
export 'services/token_store.dart';
export 'theme/app_colors.dart';
export 'theme/app_theme.dart';
export 'widgets/anime_poster.dart';
export 'widgets/back_appbar.dart';
export 'widgets/colored_tab_bar.dart';
export 'widgets/editable_stat_tile.dart';
export 'widgets/header_scrim.dart';
export 'widgets/image_viewer.dart';
export 'widgets/loading_popup.dart';
export 'widgets/media_progress_bar.dart';
export 'widgets/paged_list.dart';
export 'widgets/remote_image.dart';
export 'widgets/section_header.dart';
export 'widgets/status_chip.dart';
export 'widgets/tab_page_scroll_physics.dart';
