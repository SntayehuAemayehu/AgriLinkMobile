import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> saveToken(String t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', t);
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Map<String, String> _headers(String? token, {bool json = true}) {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  // ─── AUTH ───
  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${Config.baseUrl}/accounts/register/'),
      headers: _headers(null),
      body: jsonEncode(data),
    );
    return {'status': res.statusCode, 'body': res.body.isEmpty ? {} : jsonDecode(res.body)};
  }

  static Future<Map<String, dynamic>> login(String u, String p) async {
    final res = await http.post(
      Uri.parse('${Config.baseUrl}/accounts/login/'),
      headers: _headers(null),
      body: jsonEncode({'username': u, 'password': p}),
    );
    return {'status': res.statusCode, 'body': res.body.isEmpty ? {} : jsonDecode(res.body)};
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${Config.baseUrl}/accounts/profile/'),
      headers: _headers(token),
    );
    return {'status': res.statusCode, 'body': res.body.isEmpty ? {} : jsonDecode(res.body)};
  }

  // ─── PRODUCTS ───
  static Future<List<dynamic>> listProducts({String? crop, String? region}) async {
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

  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data, {File? image}) async {
    final token = await getToken();
    if (image == null) {
      final res = await http.post(
        Uri.parse('${Config.baseUrl}/products/'),
        headers: _headers(token),
        body: jsonEncode(data),
      );
      return {'status': res.statusCode, 'body': jsonDecode(res.body)};
    } else {
      final req = http.MultipartRequest('POST', Uri.parse('${Config.baseUrl}/products/'));
      req.headers['Authorization'] = 'Bearer $token';
      data.forEach((k, v) => req.fields[k] = v.toString());
      req.files.add(await http.MultipartFile.fromPath('image', image.path));
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);
      return {'status': res.statusCode, 'body': jsonDecode(res.body)};
    }
  }

  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    final token = await getToken();
    final res = await http.delete(
      Uri.parse('${Config.baseUrl}/products/$id/'),
      headers: _headers(token),
    );
    return {'status': res.statusCode};
  }

  // ─── ORDERS ───
  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('${Config.baseUrl}/orders/create/'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    return {'status': res.statusCode, 'body': res.body.isEmpty ? {} : jsonDecode(res.body)};
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

  static Future<bool> updateOrderStatus(int id, Map<String, dynamic> updates) async {
    final token = await getToken();
    final res = await http.patch(
      Uri.parse('${Config.baseUrl}/orders/$id/status/'),
      headers: _headers(token),
      body: jsonEncode(updates),
    );
    return res.statusCode == 200;
  }

  static Future<Map<String, dynamic>> rateOrder(int orderId, int stars, String comment) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('${Config.baseUrl}/orders/rate/'),
      headers: _headers(token),
      body: jsonEncode({'order': orderId, 'stars': stars, 'comment': comment}),
    );
    return {'status': res.statusCode, 'body': jsonDecode(res.body)};
  }

  // ─── PRICES ───
  static Future<List<dynamic>> marketPrices({String? crop, String? region}) async {
    final token = await getToken();
    var url = '${Config.baseUrl}/prices/';
    final params = <String, String>{};
    if (crop != null && crop.isNotEmpty) params['crop'] = crop;
    if (region != null && region.isNotEmpty) params['region'] = region;
    if (params.isNotEmpty) url += '?' + Uri(queryParameters: params).query;
    final res = await http.get(Uri.parse(url), headers: _headers(token));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  // ─── LOGISTICS ───
  static Future<List<dynamic>> openTransports() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${Config.baseUrl}/logistics/open/'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> myTransports() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${Config.baseUrl}/logistics/mine/'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> myJobs() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${Config.baseUrl}/logistics/jobs/'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<Map<String, dynamic>> createTransport(Map<String, dynamic> data) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('${Config.baseUrl}/logistics/create/'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    return {'status': res.statusCode, 'body': jsonDecode(res.body)};
  }

  static Future<bool> acceptTransport(int id) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('${Config.baseUrl}/logistics/$id/accept/'),
      headers: _headers(token),
    );
    return res.statusCode == 200;
  }

  static Future<bool> updateTransportStatus(int id, String status) async {
    final token = await getToken();
    final res = await http.patch(
      Uri.parse('${Config.baseUrl}/logistics/$id/status/'),
      headers: _headers(token),
      body: jsonEncode({'status': status}),
    );
    return res.statusCode == 200;
  }

  // ─── ADMIN ENDPOINTS ───
  static Future<List<dynamic>> adminGetAllUsers() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${Config.baseUrl}/accounts/admin/users/'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> adminGetAllProducts() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${Config.baseUrl}/products/admin/all/'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }
}