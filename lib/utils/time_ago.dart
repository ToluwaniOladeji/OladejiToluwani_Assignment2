import 'package:intl/intl.dart';

String timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'Just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} hr${d.inHours == 1 ? '' : 's'} ago';
  if (d.inDays < 7) return '${d.inDays} day${d.inDays == 1 ? '' : 's'} ago';
  return DateFormat.MMMd().format(t);
}
