# Cache-Backed Pagination Refactor

## Problem

The app loads every anime/manga into memory at once, which is inefficient:

1. **Cold start blocks on the entire anime list.** `Loading._finishSetup()`
   (`lib/pages/loading.dart:28`) awaits `loadAnimeList()` before navigating to
   `Home`. With a 1,500-title list that is ~15 sequential round trips before
   anything renders. Manga already loads lazily, so anime is inconsistent.
2. **Tiny page size.** `_pageSize = 100`
   (`lib/services/mal_repository.dart:13`), but MAL's user list endpoint allows
   `limit` up to **1000**.
3. **Unused fields fetched.** `_listFields` / `_mangaListFields` request
   `synopsis`, `alternative_titles`, `genres`, `studios`, `mean`, `rank`,
   `popularity`, `source`, `rating`, dates, etc., but the list models only read
   `id`, `title`, `main_picture`, counts, `status`, and `list_status`. Large
   payloads parsed and discarded on every load.
4. **Everything resident + duplicated across buckets.** `globalAnimeList` and
   `lists[status]` both hold the full set; updates do O(n) `indexWhere` scans
   (`lib/services/global_controller.dart:97`). The full list is only kept to
   support local search (`lib/pages/search.dart:29`).

Rendering is already fine (`ListView.builder` virtualizes) — this is a
data-layer problem.

## Confirmed decisions

- `sqflite` + `path_provider` disk cache
- Full background sync on launch (page size 1000, trimmed fields)
- Offline edits: require network, no outbox queue
- Full refactor with cache-backed pagination
- Search over the local cache

> Note: MAL has **no** "search my list" endpoint — `/anime?q=` searches the whole
> catalog, not the user's list. So "flexible" search resolves to: local cache
> search, plus the guarantee that background sync makes the cache complete. Show a
> subtle "syncing your list…" hint if a query is typed before sync finishes. A
> separate catalog search can be added later if wanted.

## Target architecture

```
MAL API ──(background full sync, limit=1000, trimmed fields)──▶ LocalStore (sqflite)
                                                                     │
UI (paged ListView) ◀──(LIMIT/OFFSET per status, LIKE search)────────┘
```

Network is a few bulk requests; the UI reads bounded pages from disk, so resident
memory stays flat regardless of list size. This addresses load time, memory,
bandwidth, and API call count at once.

## Phase 1 — Local store

New `lib/services/local_store.dart`:

- Lazy `Future<Database>`, `openDatabase` at `getDatabasesPath()/miru.db`,
  schema version constant + `onUpgrade` hook.
- Tables `anime` and `manga` mirroring model fields plus `user_status`,
  `sort_order` (to preserve MAL list order), and `synced_at`.
- Index `(user_status, sort_order)` on each table.
- API:
  - `replaceStatus(...)` — transaction + `Batch` upsert, assigns `sort_order`
  - `pageAnime(status, offset, limit)` / `countAnime(status)`
  - `searchAnime(query, offset, limit)` using `LIKE ... COLLATE NOCASE`
  - `clearAll()`
  - Manga equivalents
- Clear on logout / account switch.

`pubspec.yaml`: add `sqflite`, `path_provider`; dev dep `sqflite_common_ffi`
for in-memory store tests (optional but recommended).

## Phase 2 — Repository / API

`lib/services/mal_repository.dart`:

- `_pageSize` 100 → `1000` (`lib/services/mal_repository.dart:13`).
- Trim `_listFields` to `"list_status,num_episodes,status"` and
  `_mangaListFields` to `"list_status,num_chapters,num_volumes,status"`.
  Drops `synopsis`, `alternative_titles`, `genres`, `studios`, `mean`, `rank`,
  `popularity`, `source`, `rating`, dates — all unused by list models and the
  biggest payload/parse cost.
- Replace `fetchAnimeList()` / `fetchMangaList()` with
  `fetchAnimeListPage({offset, limit, status})` returning items + `hasMore`,
  and the manga equivalent. Keep detail/update methods as-is.

## Phase 3 — Controller

`lib/services/global_controller.dart`:

- Remove `globalAnimeList` / `lists` / `globalMangaList` / `mangaLists`
  in-memory buckets; own a `LocalStore`.
- Add `syncAnime()` / `syncManga()` / `syncAll()`: page the API, `replaceStatus`
  per status, flip `*Syncing` flags, `notifyListeners()`.
- Expose paged reads (`pageAnime`, `countAnime`, `searchAnime`, …) instead of
  whole lists.
- `updateAnime` / `updateManga`: PATCH first (require-online), on success update
  the DB row and `notifyListeners()`; rethrow on failure so existing snackbars in
  the detail pages keep working. On status change, reinsert at top to match
  current behavior.
- Keep `GlobalControllerScope` / `ChangeNotifier` so widget integration stays
  familiar.

## Phase 4 — UI

- `lib/pages/loading.dart`: stop awaiting the full list; only restore session +
  fetch user, then navigate. Kick off `syncAll()` fire-and-forget (guarded once).
- Introduce a small `PagedSource<T>` abstraction and a shared paged list widget
  so status buckets and search reuse one implementation.
- `lib/widgets/list_container.dart` / `manga_list_container.dart`: own a
  `ScrollController`, load first page, load next near the end, show a trailing
  spinner, `RefreshIndicator` re-syncs the visible status.
- `lib/pages/search.dart`: query `LocalStore` (paged + debounced) instead of
  filtering `globalAnimeList`.
- Per-tab states: spinner if syncing and empty; cached content plus sync progress
  if partially loaded; empty/error states otherwise.

## Phase 5 — Cleanup & tests

- Clear DB on sign-out (wire into `Home._confirmLogout` at
  `lib/pages/home.dart:89`).
- Update `Search` / containers for the new controller API; remove dead fields.
- Existing physics test is unaffected. Add store tests (in-memory) and a
  controller test with a fake repository.
- No change to details-page field requests.

## Files

New:

- `lib/services/local_store.dart`
- `lib/widgets/paged_list.dart` (or similar)

Modified:

- `pubspec.yaml`
- `lib/services/mal_repository.dart`
- `lib/services/global_controller.dart`
- `lib/pages/loading.dart`
- `lib/pages/home.dart`
- `lib/widgets/list_container.dart`
- `lib/widgets/manga_list_container.dart`
- `lib/pages/search.dart`
- `lib/main.dart` (if DB init needs it)

## Risks / tradeoffs

- Full sync on launch downloads everything, but at limit=1000 with trimmed fields
  it is a handful of small requests; disk-backed so memory is bounded.
- First-ever launch shows empty lists until the first sync lands (progress
  indicators mitigate).
- Update-by-status needs `sort_order` reassignment to keep ordering stable;
  handled in the store.
- Schema versioning needed now for future model/field changes.

## Open questions

- Keep the `PagedSource` abstraction or use per-container logic?
- Add `LocalStore` tests now or defer?
