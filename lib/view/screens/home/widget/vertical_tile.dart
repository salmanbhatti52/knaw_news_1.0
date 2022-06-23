import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knaw_news/util/dimensions.dart';
import 'package:knaw_news/util/images.dart';
import 'package:knaw_news/util/styles.dart';

class VerticalTile extends StatelessWidget {
  String icon;
  String title;
  bool isBlack;
  void Function()? onTap;
  VerticalTile({required this.icon,required this.title,this.onTap,this.isBlack=false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Container(
          child: Column(
            children:[
              SvgPicture.asset(icon,height: icon.contains("face")?14:12,width: icon.contains("face")?14:12,),
              Text(title,style: openSansRegular.copyWith(fontSize:Dimensions.fontSizeExtraSmall,color: isBlack?Colors.black:Colors.grey),),
            ]
          ),
        ),
      ),
    );
  }
}
