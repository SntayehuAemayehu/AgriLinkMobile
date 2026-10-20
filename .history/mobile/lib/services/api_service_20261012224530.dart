import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Map<String, String> _headers(String? token, {bool json = true}) {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  // AUTH
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse('${Config.baseUrl}/accounts/register/'),
      headers: _headers(null),
      body: jsonEncode(data),
    );
    return {'status': res.statusCode, 'body': jsonDecode(res.body)};
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('${Config.baseUrl}/accounts/login/'),
      headers: _headers(null),
      body: jsonEncode({'username': username, 'password': password}),
    );
    return {'status': res.statusCode, 'body': jsonDecode(res.body)};
  }

  static Future<Map<String, dynamic>> profile() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${Config.baseUrl}/accounts/profile/'),
      headers: _headers(token),
    );
    return {'status': res.statusCode, 'body': jsonDecode(res.body)};
  }

  // PRODUCTS
  static Future<List<dynamic>> listProducts({
    String? crop,
    String? region,
  }) async {
    final token = await getToken();
    var url = '${Config.baseUrl}/products/';
    final params = <String, String>{};
    if (crop != null && crop.isNotEmpty) params['crop'] = crop;
    if (region != null && region.isNotEmpty) params['region'] = region;
    if (params.isNotEmpty) url += '?' + Uri(queryParameters: params).query;

    final res = await http.get(Uri.parse(url), headers: _headers(token));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> myProducts() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${Config.baseUrl}/products/mine/'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> data,
  ) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('${Config.baseUrl}/products/'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    return {'status': res.statusCode, 'body': jsonDecode(res.body)};
  }

  // ORDERS
  static Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> data,
  ) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('${Config.baseUrl}/orders/create/'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    return {'status': res.statusCode, 'body': jsonDecode(res.body)};
  }

  static Future<List<dynamic>> myOrders() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${Config.baseUrl}/orders/mine/'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> farmerOrders() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${Config.baseUrl}/orders/farmer/'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<bool> updateOrderStatus(int orderId, String status) async {
    final token = await getToken();
    final res = await http.patch(
      Uri.parse('${Config.baseUrl}/orders/$orderId/status/'),
      headers: _headers(token),
      body: jsonEncode({'status': status}),
    );
    return res.statusCode == 200;
  }
}
