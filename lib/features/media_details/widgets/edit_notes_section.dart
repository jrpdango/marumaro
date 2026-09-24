part of '../edit_list_page.dart';

/// The notes section: free-form comments.
class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.comments});

  final TextEditingController comments;

  @override
  Widget build(BuildContext context) {
    return _EditSection(
      title: "Notes",
      child: TextField(
        controller: comments,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: "Your comments",
        ),
      ),
    );
  }
}
