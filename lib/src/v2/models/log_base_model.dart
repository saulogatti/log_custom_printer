// ignore_for_file: public_member_api_docs, sort_constructors_first
class TagLog {
  List<String> tags = [];
  final List<String> restrictedTags;
  TagLog({required this.restrictedTags});
  void addTag(String tag) {
    tag = tag.formattedName;
    if (restrictedTags.contains(tag)) {
      throw Exception("Tag '$tag' is restricted and cannot be added.");
    }
    tags.add(tag);
  }

  bool hasTag(String tag) {
    return tags.contains(tag.formattedName);
  }

  void removeTag(String tag) {
    tags.remove(tag.formattedName);
  }
}

extension on String {
  String get formattedName => trim().toLowerCase();
}
