import 'dart:io';

import 'package:flutter/material.dart';
import '/../constants.dart';
import 'package:image_picker/image_picker.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _selectedStars = 0;
  List<XFile> _images = [];
  List<XFile> _videos = [];

  final ImagePicker _picker = ImagePicker();

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(pickedFile);
      });
    }
  }

  void _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videos.add(pickedFile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đánh giá sản phẩm', style: TextStyle(color: Constants.white)),
        backgroundColor: Constants.primaryColor,
        actions: [
          TextButton(
            onPressed: () {
              // Hành động khi bấm nút "Gửi"
            },
            child: Text(
              'Gửi',
              style: TextStyle(color: Constants.white, fontSize: 18),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: Image.asset('assets/images/item_1.png', height: 80),
              title: Text('Bánh tráng phơi sương', style: TextStyle(fontSize: 18)),
              subtitle: Text('Phân loại: Sốt tắc', style: TextStyle(fontSize: 16, color: Constants.lightTextColor)),
            ),
            Divider(),
            ListTile(
              title: Text('Chất lượng sản phẩm', style: TextStyle(fontSize: 16)),
              subtitle: Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedStars = index + 1;
                      });
                    },
                  );
                }),
              ),
              trailing: Text('Tuyệt vời', style: TextStyle(fontSize: 14, color: Constants.primaryColor)),
            ),
            SizedBox(height: 10),
            Text(
              'Thêm 50 ký tự và 1 hình ảnh và 1 video để nhận đến 200 xu',
              style: TextStyle(fontSize: 15, color: Colors.orange),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.camera_alt, color: Colors.pinkAccent),
                  label: Text('Thêm Hình ảnh', style: TextStyle(color: Colors.pinkAccent)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.pinkAccent),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickVideo,
                  icon: Icon(Icons.videocam, color: Colors.pinkAccent),
                  label: Text('Thêm Video', style: TextStyle(color: Colors.pinkAccent)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.pinkAccent),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_images.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _images.map((image) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Image.file(File(image.path), height: 100),
                  );
                }).toList(),
              ),
            if (_videos.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _videos.map((video) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(video.name), // Hiển thị tên video
                  );
                }).toList(),
              ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Hãy chia sẻ nhận xét cho sản phẩm này bạn nhé!',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
