import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventaire_mobile/Models/Inventaire.dart';

import '../Models/UserSoc.dart';



class InventaireController extends GetxController {

  final _inventaires = RxList<Inventaire>([]);
  final _usersocs = RxList<UserSoc>([]);
  RxList<Inventaire> get inventaires => _inventaires;
  RxList<UserSoc> get usersocs => _usersocs;
  final storage = FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    fetchInventaires();
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await storage.read(key: "jwt_token");
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Access-Control-Allow-Origin': '*', // This is the cross-origin header
    };
  }
  //http://localhost:44328/Api/SocieteUser/GetusersocParUser?codeuser=
  Future<List<UserSoc>> fetchUserSocs() async {
    try {
      final token = (await storage.read(key: "jwt_token"))?.replaceAll('"', '');
      final codeuser = (await storage.read(key: "codeuser"));
      final url = 'http://localhost:44328/Api/SocieteUser/GetusersocParUser?codeuser=';
      final encodedUrl = Uri.parse(url + codeuser!); // added token to the url
      final response = await http.get(
        encodedUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Access-Control-Allow-Origin': '*', // This is the cross-origin header
        },
      );
      if (response.statusCode == 200) {
        final Iterable jsonList = json.decode(response.body);
        final List<UserSoc> usersocs = [];
        usersocs.addAll(jsonList.map((model) => UserSoc.fromJson(model)));
        return usersocs;
      } else {
        // Handle authentication errors
        print('Failed to fetch usersocs due to authentication error');
        throw Exception(
            'Authentication error occurred while fetching inventaires');
      }
    } catch (e) {
      print('Failed to fetch usersocs due to $e');
      throw Exception('Failed to fetch usersocs due to $e');
    }
  }





  Future<List<Inventaire>> fetchInventaires() async {
    try {
      final token = (await storage.read(key: "jwt_token"))?.replaceAll('"', '');
      final url = 'http://localhost:44328/api/Inventaire/GetInventaires';
      final encodedUrl = Uri.encodeFull(url);
      final response = await http.get(
        Uri.parse(encodedUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Access-Control-Allow-Origin': '*', // This is the cross-origin header
        },
      );
      if (response.statusCode == 200) {
        final Iterable jsonList = json.decode(response.body);
        _inventaires.clear();
        _inventaires.addAll(jsonList.map((model) => Inventaire.fromJson(model)));
        return _inventaires;
      } else if (response.statusCode == 401) {
        // Handle authentication errors
        print('Failed to fetch inventaires due to authentication error');
        throw Exception('Authentication error occurred while fetching inventaires');
      } else if (response.statusCode == 404) {
        // Handle not found errors
        print('Failed to fetch inventaires. Reason: ${response.reasonPhrase}');
        throw Exception('Inventaires not found');
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        // Handle server errors
        final errorMessage = response.reasonPhrase ?? 'Unknown error';
        print('Failed to fetch inventaires due to server error. Reason: $errorMessage');
        throw Exception('Server error occurred while fetching inventaires');
      } else {
        // Handle other errors
        final errorMessage = response.reasonPhrase ?? 'Unknown error';
        print('Failed to fetch inventaires. Reason: $errorMessage');
        throw Exception('Unexpected error occurred while fetching inventaires');
      }
    } on SocketException catch (e) {
      // Handle network error
      print('Failed to fetch inventaires due to network error. Reason: $e');
      throw Exception('Network error occurred while fetching inventaires');
    } on TimeoutException catch (e) {
      // Handle timeout error
      print('Failed to fetch inventaires due to timeout error. Reason: $e');
      throw Exception('Timeout error occurred while fetching inventaires');
    } on Exception catch (e) {
      // Handle other exceptions
      print('Failed to fetch inventaires due to unexpected error. Reason: $e');
      throw Exception('Unexpected error occurred while fetching inventaires');
    }
  }



  Future<void> selectionnerArticles(String id, Inventaire invphysique) async {
    final url = 'http://localhost:44328/api/Inventaire/SelectionnerArticles?id=$id';
    final token = (await storage.read(key: "jwt_token"))!.replaceAll('"', '');
    final encodedUrl = Uri.parse(url);

    final response = await http.put(
      encodedUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Access-Control-Allow-Origin': '*', // This is the cross-origin header
      },
      body: json.encode(invphysique.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update inventory: ${response.body}');
    }
  }
  Future<void> SaisiComptage(String id, Inventaire invphysique) async {
    final url = 'http://localhost:44328/api/Inventaire/SaisirComptagePhysique?id=$id';
    final token = (await storage.read(key: "jwt_token"))!.replaceAll('"', '');
    final encodedUrl = Uri.parse(url);

    final response = await http.put(
      encodedUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Access-Control-Allow-Origin': '*', // This is the cross-origin header
      },
      body: json.encode(invphysique.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update inventory: ${response.body}');
    }
  }
  Future<void> CloturerInventaire(String id, Inventaire invphysique) async {
    final url = 'http://localhost:44328/api/Inventaire/CloturerInventaire/?id=$id';
    final token = (await storage.read(key: "jwt_token"))!.replaceAll('"', '');
    final encodedUrl = Uri.parse(url);

    final response = await http.put(
      encodedUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Access-Control-Allow-Origin': '*', // This is the cross-origin header
      },
      body: json.encode(invphysique.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update inventory: ${response.body}');
    }
  }


}