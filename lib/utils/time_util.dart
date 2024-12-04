import 'package:intl/intl.dart';

String formatUpdatedAt(DateTime updatedAt) {
  final formatter = DateFormat('yyyy/MM/dd HH:mm:ss');
  return formatter.format(updatedAt);
}