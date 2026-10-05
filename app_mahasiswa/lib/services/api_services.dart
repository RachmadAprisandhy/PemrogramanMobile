import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';
 
class ApiService {
  // Emulator Android: 10.0.2.2 = localhost komputer
  static const String baseUrl = 'http://10.0.2.2:8000/api/mahasiswa';
 
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
 
  // READ - ambil semua data
  Future<List<Mahasiswa>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl), headers: headers);
 
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);       // String -> Map
      final List data = body['data'];         // ambil array "data"
      return data.map((e) => Mahasiswa.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat data (${res.statusCode})');
  }
   Future<Mahasiswa> create(Mahasiswa m) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(m.toJson()),
    );
    if (res.statusCode == 201) {
      return Mahasiswa.fromJson(jsonDecode(res.body)['data']);
    }
    throw Exception(_pesanError(res));
  }
 
  // UPDATE - ubah data berdasarkan id
  Future<Mahasiswa> update(int id, Mahasiswa m) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: jsonEncode(m.toJson()),
    );
    if (res.statusCode == 200) {
      return Mahasiswa.fromJson(jsonDecode(res.body)['data']);
    }
    throw Exception(_pesanError(res));
  }

}