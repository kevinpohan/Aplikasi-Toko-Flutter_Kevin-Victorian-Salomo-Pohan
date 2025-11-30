import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produk.dart';
import '../models/api_response.dart';
import '../models/login_response.dart';

class ExpiredTokenException implements Exception {
  final String message;
  ExpiredTokenException(this.message);
  @override
  String toString() => 'ExpiredTokenException: $message';
}

class ApiService {
  static const String _baseUrl = "http://10.0.2.2:8080";

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {'Content-Type': 'application/json'};
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ================== REGISTRASI ==================
  Future<ApiResponse> registrasi(
    String nama,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$_baseUrl/registrasi');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nama': nama, 'email': email, 'password': password}),
      );

      var data = json.decode(response.body);

      return ApiResponse(
        status: response.statusCode >= 200 && response.statusCode < 300,
        data: data['data'],
        message: data['message'] ?? "Registrasi gagal",
        code: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        data: null,
        message: "Error: $e",
        code: 500,
      );
    }
  }

  // ================== LOGIN ==================
  Future<LoginResponse> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(json.decode(response.body));
      } else {
        return LoginResponse(
          status: false,
          token: "",
          userEmail: email,
          userId: 0,
        );
      }
    } catch (e) {
      return LoginResponse(
        status: false,
        token: "Error: $e",
        userEmail: "",
        userId: 0,
      );
    }
  }

  // ================== GET PRODUK ==================
  Future<List<Produk>> getProduk() async {
    final url = Uri.parse('$_baseUrl/produk');
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body)['data'];
      return jsonData.map((json) => Produk.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw ExpiredTokenException("Sesi habis. Silakan login kembali.");
    } else {
      throw Exception("Gagal memuat produk: ${response.statusCode}");
    }
  }

  // ================== CREATE PRODUK ==================
  Future<ApiResponse> createProduk(Produk produk) async {
    final url = Uri.parse('$_baseUrl/produk');
    final headers = await _getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(produk.toJson()),
    );

    var res = json.decode(response.body);

    return ApiResponse(
      status: response.statusCode >= 200 && response.statusCode < 300,
      data: res['data'],
      message: res['message'] ?? "Gagal menambahkan produk",
      code: response.statusCode,
    );
  }

  // ================== UPDATE PRODUK ==================
  Future<ApiResponse> updateProduk(String id, Produk produk) async {
    final url = Uri.parse('$_baseUrl/produk/$id');
    final headers = await _getAuthHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(produk.toJson()),
    );

    var res = json.decode(response.body);

    return ApiResponse(
      status: response.statusCode == 200,
      data: res['data'],
      message: res['message'] ?? "Gagal update produk",
      code: response.statusCode,
    );
  }

  // ================== DELETE PRODUK ==================
  Future<ApiResponse> deleteProduk(String id) async {
    final url = Uri.parse('$_baseUrl/produk/$id');
    final headers = await _getAuthHeaders();
    final response = await http.delete(url, headers: headers);

    var res = json.decode(response.body);

    return ApiResponse(
      status: response.statusCode == 200,
      data: res['data'],
      message: res['message'] ?? "Gagal menghapus produk",
      code: response.statusCode,
    );
  }
}
