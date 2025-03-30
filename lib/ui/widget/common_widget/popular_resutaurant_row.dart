import 'package:flutter/material.dart';
import '/../ui/screens/detail_dish_page.dart';

import '../../../constants.dart';
import '../common/color_extension.dart';

class PopularRestaurantRow extends StatelessWidget {
  final Map pObj;
  final VoidCallback onTap;
  const PopularRestaurantRow({super.key, required this.pObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailDish(resID: pObj["id"]) //replace with your new page
              )
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20),
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pObj["name"],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Constants.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                      Text(
                        pObj["address"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: TColor.secondaryText, fontSize: 11),
                      ),

                      const SizedBox(
                        width: 8,
                      ),
                      ],
                    ),
                    Text(
                      pObj["opening_hours"],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: TColor.secondaryText, fontSize: 11),
                    ),
                  ],
                ),
             ),

          ],
        ),
      ),
    );
  }
}
