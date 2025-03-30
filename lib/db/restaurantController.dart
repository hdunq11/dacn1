import '/../db/userController.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantController {
  //getAll
  Future<ApiResponse> getTop() async {
    var url = Uri.parse('http://10.0.2.2:8000/api/restaurant/getAllHome');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }
  //getItem
  Future<ApiResponse> getItem(int id) async {
    var url = Uri.parse('http://10.0.2.2:8000/api/restaurant/getItem/${id}');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }


// //register
// Future<ApiResponse> signUp(String name, String phone, String email, String password) async {
//   var url = Uri.parse('http://10.0.2.2:8000/api/register');
//   var response = await http.post(
//     url,
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(<String, String>{
//       'name': name,
//       'phone': phone,
//       'email': email,
//       'password': password,
//       'role': 'user',
//     }),
//   );
//
//   ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
//   return apiResponse;
// }
}