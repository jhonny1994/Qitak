class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.deepLink,
    this.title = '',
    this.body = '',
    this.timestampLabel = '',
    this.categoryLabel = '',
    this.data = const <String, dynamic>{},
    this.createdAt,
    this.isUnread = false,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String timestampLabel;
  final String categoryLabel;
  final String deepLink;
  final Map<String, dynamic> data;
  final DateTime? createdAt;
  final bool isUnread;
}
