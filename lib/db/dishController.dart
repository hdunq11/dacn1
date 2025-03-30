import '/../db/userController.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DishController {
  //getAll
  Future<ApiResponse> getTop() async {
    var url = Uri.parse('http://10.0.2.2:8000/api/dish/getAllHome');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }

  Future<ApiResponse> getRecent() async {
    var url = Uri.parse('http://10.0.2.2:8000/api/dish/getRecent');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }

  //get list by type
  Future<ApiResponse> search(String type, int res_id) async {
    var url = Uri.parse('http://10.0.2.2:8000/api/dish/search/${type}/${res_id}');
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