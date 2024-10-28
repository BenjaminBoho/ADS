import 'dart:convert';
import 'package:http/http.dart';
import 'package:accident_data_storage/models/address.dart';

Future<Address?> fetchAddressFromPostalCode(String zipCode) async {
  if (zipCode.length != 7) {
    return null;
  }

  try {
    final response = await get(
      Uri.parse('https://zipcloud.ibsnet.co.jp/api/search?zipcode=$zipCode'),
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
