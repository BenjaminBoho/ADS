import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:accident_data_storage/models/address.dart';

Future<Address?> fetchAddressFromZipCode(String zipCode) async {
  if (zipCode.length != 7) {
    return null;
  }

  try {
    final zipCodeApiUrl = dotenv.env['ZIPCODE_API_URL'] ?? '';
    final response = await get(
      Uri.parse('$zipCodeApiUrl$zipCode'),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final result = jsonDecode(response.body);
    if (result['results'] == null) {
      return null;
    }

    final addressMap = (result['results'] as List).first;
    return Address.fromJson(addressMap); // Addressオブジェクトとして返す
  } catch (e) {
    // エラーハンドリング
    return null;
  }
}
