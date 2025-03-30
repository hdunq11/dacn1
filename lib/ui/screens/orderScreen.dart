import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '/../constants.dart';
import '/../model/dishes.dart';
import '/../ui/screens/detail_dish_page.dart';
import '/../ui/screens/reviewScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../db/cartController.dart';
import '../../db/firebaseController.dart';
import '../../db/orderController.dart';
import '../../db/restaurantController.dart';
import '../../db/userController.dart';
import '../../model/firebaseModel.dart';
import '../../model/restaurants.dart';

void main() {
  runApp(MaterialApp(
    home: OrderScreen(),
    theme: ThemeData(
      primaryColor: Constants.primaryColor,
    ),
  ));
}

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _getUserId().then((_) {
      _getItem();
    });
  }

  var user_id = 0;
  // Lấy user_id
  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id')!;
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  List<dynamic> list = [];
  Map<int, Map<dynamic, dynamic>> cart = {};
  Future<void> _getItem() async {
    try {
      ApiResponse response = await CartController().getAllByUser(user_id);
      if (response.statusCode == 200) {
        setState(() {
          list = jsonDecode(response.body);
          list.forEach((item) {
            cart[item['id']] = {
              'restaurant_name': item['restaurant_name'],
              'address': item['address'],
              'img': item['img'],
              'count': item['count'],
            };
          });
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      // Xử lý lỗi (nếu có)
      print(error);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng',
            style:
                TextStyle(color: Constants.white, fontWeight: FontWeight.bold)),
        backgroundColor: Constants.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Constants.white,
          labelStyle: TextStyle(fontSize: 18.0, color: Constants.white),
          tabs: [
            Tab(text: 'Đang đến'),
            Tab(text: 'Lịch sử'),
            Tab(text: 'Đánh giá'),
            Tab(text: 'Giỏ hàng'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DangDenTab(),
          LichSuTab(),
          DanhGiaTab(),
          GioHangTab(cart),
        ],
      ),
    );
  }
}

class DangDenTab extends StatelessWidget {

  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }


  final FirebaseController _controller = FirebaseController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: _getUserId(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
    return Text("Error: ${snapshot.error}");
    } else {
      final user_id = snapshot.data ?? 0;
      return StreamBuilder<List<FirebaseModel>>(
        stream: _controller.getAll(user_id.toInt()),
        builder: (context, snapshot1) {
          if (!snapshot1.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            final orders = snapshot1.data;
            final models = snapshot1.data;
            final modelString = _controller.firebaseModelListToString(models!);
            print(modelString);
            return ListView.builder(
              itemCount: orders?.length,
              itemBuilder: (context, index) {
                final order = orders?[index];
                print("order_id: ${order?.status}");
                Future<Restaurants> _getItem(int resId) async {
                  Restaurants res = Restaurants(
                    id: 0,
                    name: '',
                    address: '',
                    phone: '',
                    opening_hours: '',
                    created_at: null,
                    updated_at: null,
                  );

                  try {
                    ApiResponse response =
                    await RestaurantController().getItem(resId);

                    if (response.statusCode == 200) {
                      Map<String, dynamic> data = jsonDecode(response.body);
                      res = Restaurants.fromMap(data);
                    }
                  } catch (error) {
                    print(error);
                  }

                  return res;
                }

                return FutureBuilder<Restaurants>(
                  future: _getItem(order!.res_id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else {
                      Restaurants? res = snapshot.data;
                      return Card(
                        margin: EdgeInsets.all(10),
                        color: Constants.backgroundTable,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Đồ ăn ${order.order_id}',
                                  style: TextStyle(
                                      color: Constants.highlightColor,
                                      fontSize: 15)),
                              SizedBox(height: 5),
                              Text("${res?.name}",
                                  style: TextStyle(
                                      color: Constants.accentColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              FutureBuilder(
                                future: OrderController()
                                    .getAllByOrder(order!.order_id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text("Error: ${snapshot.error}");
                                  } else {
                                    List<dynamic> list =
                                    jsonDecode(snapshot.data!.body);
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: list.length,
                                      itemBuilder: (context, index) {
                                        var orderItem = list[index];

                                        return Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: (orderItem['dishes'] as List).map<Widget>((item) {
                                                final prefix = 'data:image/jpeg;base64,';
                                                Uint8List? bytes;
                                                if (item['img'] != null && item['img'].startsWith(prefix)) {
                                                  var base64Image = item['img'].substring(prefix.length);
                                                  if (base64Image.length % 4 == 0) {
                                                    try {
                                                      bytes = base64Decode(base64Image);
                                                    } on FormatException {
                                                      print('Không thể giải mã hình ảnh: dữ liệu base64 không hợp lệ.');
                                                      bytes = null;
                                                    }
                                                  } else {
                                                    print('Dữ liệu hình ảnh bị hỏng: độ dài không phải là bội số của 4.');
                                                    bytes = null;
                                                  }
                                                } else {
                                                  bytes = null;
                                                }
                                                return Padding(
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                                  child: Row(
                                                    children: [
                                                      bytes != null
                                                          ? Padding(
                                                        padding: EdgeInsets.all(10),
                                                        child: Image.memory(
                                                          bytes,
                                                          width: 60,
                                                          height: 60,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                            return const Icon(Icons.error);
                                                          },
                                                        ),
                                                      )
                                                          : Padding(
                                                        padding: EdgeInsets.all(10),
                                                        child: Image.asset(
                                                          "assets/images/image.png",
                                                          width: 60,
                                                          height: 60,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        item['dish_name'],
                                                        style: TextStyle(
                                                          color: Constants
                                                              .textColor,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        "${item['quantity']}",
                                                        style: TextStyle(
                                                          color: Constants
                                                              .textColor,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                            Spacer(),
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${order.total}.000đ',
                                                  style: TextStyle(
                                                    color: Constants.primaryColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  '${orderItem['length']} món',
                                                  style: TextStyle(
                                                    color: Constants
                                                        .lightTextColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      );
    }
    },
    );
  }
}

class LichSuTab extends StatelessWidget {
  final List<Map<String, dynamic>> history = [
    {
      'id': '#05054-674530315',
      'shop': 'Highlands Coffee - Nguyễn Huệ',
      'items': [
        {'name': 'Cà phê sữa đá', 'image': 'assets/images/item_3.png'},
        {'name': 'Bánh mì thịt', 'image': 'assets/images/item_1.png'}
      ],
      'total': 85000,
      'date': '21/4 lúc 14:00',
      'status': 'Đã giao'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Constants.backgroundTable,
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(Icons.monetization_on, color: Colors.yellow),
              SizedBox(width: 10),
              Text('Đánh giá quán, nhận ngay 500 Xu',
                  style: TextStyle(color: Constants.textColor, fontSize: 16)),
              Spacer(),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Constants.textColor),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final order = history[index];
              return Card(
                margin: EdgeInsets.all(10),
                color: Constants.backgroundTable,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Đồ ăn ${order['id']}',
                          style: TextStyle(
                              color: Constants.textColor, fontSize: 16)),
                      SizedBox(height: 5),
                      Text(order['shop'],
                          style: TextStyle(
                              color: Constants.accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: order['items'].map<Widget>((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                  children: [
                                    Image.asset(item['image'], height: 60),
                                    SizedBox(width: 10),
                                    Text(item['name'],
                                        style: TextStyle(
                                            color: Constants.textColor,
                                            fontSize: 16)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${order['total']}đ',
                                  style: TextStyle(
                                      color: Constants.primaryColor,
                                      fontSize: 16)),
                              Text('${order['items'].length} món',
                                  style: TextStyle(
                                      color: Constants.lightTextColor,
                                      fontSize: 16)),
                              Text('Ngày đặt: ${order['date']}',
                                  style: TextStyle(
                                      color: Constants.lightTextColor)),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.pinkAccent,
                              ),
                              onPressed: () {},
                              child: Text(order['status']),
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.pinkAccent,
                                backgroundColor: Colors.white,
                              ),
                              onPressed: () {},
                              child: Text('Đặt lại'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DanhGiaTab extends StatelessWidget {
  final List<Map<String, dynamic>> reviews = [
    {
      'shop': 'Bee Milktea & Coffee',
      'item': 'Trà mãng cầu size L',
      'image': 'assets/images/item_1.png',
      'daysLeft': 26,
    },
    {
      'shop': 'Bánh Tráng  Quỳnh Anh',
      'item': '20 cái Phồng Sữa',
      'image': 'assets/images/item_2.png',
      'daysLeft': 25,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          margin: EdgeInsets.all(10),
          color: Constants.backgroundTable,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Image.asset(review['image'], height: 60),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review['shop'],
                          style: TextStyle(
                              color: Constants.accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text(review['item'],
                          style: TextStyle(
                              color: Constants.textColor, fontSize: 15)),
                      SizedBox(height: 5),
                      Text('Chỉ còn ${review['daysLeft']} ngày để đánh giá',
                          style: TextStyle(color: Constants.lightTextColor)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReviewScreen()),
                    );
                  },
                  child: Row(
                    children: [
                      Text('Đánh giá',
                          style: TextStyle(color: Constants.accentColor)),
                      SizedBox(width: 5),
                      Icon(Icons.monetization_on, color: Colors.yellow),
                      Text('200',
                          style: TextStyle(color: Constants.accentColor)),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Constants.accentColor.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GioHangTab extends StatelessWidget {
  final Map<int, Map<dynamic, dynamic>> cart;

  GioHangTab(this.cart);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cart.length,
      itemBuilder: (context, index) {
        int id = cart.keys.elementAt(index);
        var item = cart[id];
        return GestureDetector(
          // Sử dụng GestureDetector
          onTap: () {
            // Navigate to HomePage when card is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailDish(resID: id)),
            );
          },
          child: Card(
            margin: EdgeInsets.all(10),
            color: Constants.backgroundTable,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  item?['img'] != null
                      ? Image.memory(
                          base64Decode(item?['img']
                              .substring('data:image/jpeg;base64,'.length)),
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.error),
                        )
                      : Icon(Icons.image_not_supported),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item?['restaurant_name'],
                            style: TextStyle(
                                color: Constants.accentColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text(item?['address'],
                            style: TextStyle(
                                color: Constants.textColor, fontSize: 15)),
                        SizedBox(height: 5),
                        Text("${item?['count']} sản phẩm",
                            style: TextStyle(color: Constants.lightTextColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
