import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import '/../db/userController.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderController {
  //add
  Future<ApiResponse> createOrder(int user_id, int restaurant_id, int price, int ship, int discount, int total_amount, int payment) async {
    print("${user_id} - ${restaurant_id} - ${price} - ${ship} - ${discount} - ${total_amount} - ${payment}");
    var url = Uri.parse('http://10.0.2.2:8000/api/order/create');

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'user_id': user_id,
        'restaurant_id': restaurant_id,
        'price': price,
        'ship': ship,
        'discount': discount,
        'total_amount': total_amount,
        'payment': payment,
      }),
    );
    print(response.body);
    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);

    return apiResponse;
  }

  //add
  Future<ApiResponse> createOrderItem(String order_id, String user_id, String restaurant_id, String option) async {
    print("${order_id} - ${user_id} - ${restaurant_id} - ${option}");
    var url = Uri.parse('http://10.0.2.2:8000/api/orderItems/create');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': user_id,
        'restaurant_id': restaurant_id,
        'order_id': order_id,
        'option': option,
      }),
    );
    print(response.body);
    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }


  //getAllByUser
  Future<ApiResponse> getAll(int user_id) async {
    var url = Uri.parse('http://10.0.2.2:8000/api/order/getItems/${user_id}');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }

  //getAllByOrder_id
  Future<ApiResponse> getAllByOrder(int order_id) async {
    var url = Uri.parse('http://10.0.2.2:8000/api/orderItems/getAll/${order_id}');
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