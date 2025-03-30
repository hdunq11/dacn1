import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiResponse {
  final int statusCode;
  final String body;

  ApiResponse(this.statusCode, this.body);
}

class UserController {
  //login
  Future<ApiResponse> signIn(String email, String password) async {
    var url = Uri.parse('http://10.0.2.2:8000/api/login');
    var body = jsonEncode(<String, String>{
      'email': email,
      'password': password,
    });

    print("Sending: $body");  // Thêm vào đây

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    print("Received: ${response.body}");  // Và thêm vào đây

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }


  //register
  Future<ApiResponse> signUp(String name, String phone, String email, String password) async {
    var url = Uri.parse('http://10.0.2.2:8000/api/register');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'role': 'user',
      }),
    );

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }

  //getItem
  Future<ApiResponse> getItem(int id) async {
    var url = Uri.parse('http://10.0.2.2:8000/api/user/getUser/${id}');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }
}