import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

String formatUpdatedAt(DateTime updatedAt) {
  final utcUpdatedAt = updatedAt.toUtc();
  final localUpdatedAt = utcUpdatedAt.toLocal();
  final formatter = DateFormat('yyyy/MM/dd HH:mm:ss');
  // if (kDebugMode) {
  //   print('Local UpdatedAt: $localUpdatedAt');
  // } 
  return formatter.format(localUpdatedAt);
}

void debugTimeConversion(DateTime updatedAt) {
  final utcUpdatedAt = updatedAt.toUtc();
  if (kDebugMode) {
    print('UTC UpdatedAt: $utcUpdatedAt');
  }

  final localUpdatedAt = utcUpdatedAt.toLocal();
  if (kDebugMode) {
    print('Local UpdatedAt: $localUpdatedAt');
  }

  final formatter = DateFormat('yyyy/MM/dd HH:mm:ss');
  if (kDebugMode) {
    print('Formatted Local UpdatedAt: ${formatter.format(localUpdatedAt)}');
  }
}
