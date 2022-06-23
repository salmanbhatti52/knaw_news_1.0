import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:knaw_news/mixin/data.dart';
import 'package:knaw_news/model/post_model.dart';
import 'package:knaw_news/services/dio_service.dart';
import 'package:knaw_news/util/dimensions.dart';
import 'package:knaw_news/util/images.dart';
import 'package:knaw_news/util/styles.dart';
import 'package:knaw_news/view/base/custom_image.dart';
import 'package:knaw_news/view/base/custom_snackbar.dart';
import 'package:knaw_news/view/base/loading_dialog.dart';
import 'package:knaw_news/view/screens/comment/comment.dart';
import 'package:knaw_news/view/screens/home/image_view.dart';
import 'package:knaw_news/view/screens/home/widget/dot_news.dart';
import 'package:knaw_news/view/screens/home/widget/report_dialog.dart';
import 'package:knaw_news/view/screens/home/widget/small_transition.dart';
import 'package:knaw_news/view/screens/home/widget/user_info.dart';
import 'package:knaw_news/view/screens/home/widget/vertical_tile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:translator/translator.dart';


class FullTransition extends StatefulWidget {
  PostDetail? postDetail;
  FullTransition({Key? key, this.postDetail,}) : super(key: key);

  @override
  State<FullTransition> createState() => _FullTransitionState();
}

class _FullTransitionState extends State<FullTransition> {
  bool isComment=false;
  bool isReadMore=false;
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      translate();
    });
  }
  _launchURL(String _url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: MediaQuery.of(context).size.width*0.9,
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Detail
              UserInfo(postDetail: widget.postDetail,),
              // Post Title
              Container(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.01,),
                width: MediaQuery.of(context).size.width*0.9,
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Wrap(
                        children:[
                          Text(widget.postDetail!.title??'',maxLines:2,style: openSansSemiBold.copyWith(fontSize:Dimensions.fontSizeDefault,color:Colors.black),),
                          //postDetail!.description!.length<100?postDetail!.description!+"\n":
                        ]),
                  ],
                ),
              ),
              // post Date
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(widget.postDetail!.category=='Events'&&widget.postDetail!.eventNewsStartDate!=null&&widget.postDetail!.eventNewsEndDate!=null?widget.postDetail!.eventNewsStartDate!+" "+widget.postDetail!.eventNewsEndDate!:widget.postDetail!.createdAt??'',style: openSansRegular.copyWith(fontSize:Dimensions.fontSizeSmall,color:Colors.grey),),
              ),

              // News Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Stack(
                  children: [
                    Text(
                      widget.postDetail!.description!,
                      maxLines: isReadMore?100:3,
                      style: openSansRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.black,overflow: TextOverflow.fade),
                    ),
                    isReadMore?SizedBox():
                    Positioned(
                      bottom: 0,right: 0,
                        child: Container(
                          width: 100,
                          color: Colors.white,
                          child: InkWell(
                              onTap: (){
                                isReadMore=true;
                                widget.postDetail!.isViewed!?null:viewPost();
                                setState(() {
                                });
                              },
                              child: Text(".....(${AppData().language!.readMore})",style: openSansBold.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.amber))
                          ),
                        )
                    ),
                  ],
                ),
              ),
              // CustomImage(
              //   image: Images.placeholder,
              //   height: MediaQuery.of(context).size.height*0.25,
              //   width: MediaQuery.of(context).size.width*0.9,
              //   fit: BoxFit.cover,
              // ),

              //Post Image
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: ClipRRect(
                  child: widget.postDetail!.postPicture == null || widget.postDetail!.postPicture == "" ? SizedBox():
                  GestureDetector(
                    onTap: () => Get.to(ImageView(image: widget.postDetail!.postPicture,)),
                    child: Image.network(
                      widget.postDetail!.postPicture??'',
                      height: MediaQuery.of(context).size.height*0.25, width: MediaQuery.of(context).size.width*0.9,fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Action Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    VerticalTile(icon: widget.postDetail!.category=="Opinion"?widget.postDetail!.isHappyReacted!?Images.like:Images.like_bold:widget.postDetail!.isHappyReacted!?Images.smile_face:Images.smile_face_bold, title: widget.postDetail!.happyReactions.toString(),isBlack: true,onTap: widget.postDetail!.category=="Opinion"?likeOpinion:happyReact,),
                    Expanded(child: Container()),
                    VerticalTile(icon: widget.postDetail!.category=="Opinion"?widget.postDetail!.isSadReacted!?Images.dislike:Images.dislike_bold:widget.postDetail!.isSadReacted!?Images.sad_face:Images.sad_face_bold, title: widget.postDetail!.sadReactions.toString(),isBlack: true,onTap: widget.postDetail!.category=="Opinion"?dislikeOpinion:sadReact,),
                    Expanded(child: Container()),
                    VerticalTile(icon: widget.postDetail!.isBookmarked=="true"?Images.bookmark_bold:Images.bookmark, title: AppData().language!.bookmarks,onTap: bookmarkPost,),
                    Expanded(child: Container()),
                    VerticalTile(icon: Images.comment, title: widget.postDetail!.totalComments.toString(),isBlack: true,onTap: (){
                      //Get.bottomSheet(CommentScreen(postDetail: widget.postDetail,));
                      isComment=!isComment;
                      setState(() {

                      });
                    }),
                    Expanded(child: Container()),
                    widget.postDetail!.externalLink!.isURL?VerticalTile(icon: Images.link, title: AppData().language!.source,onTap: () => _launchURL(widget.postDetail!.externalLink!.contains("http")?widget.postDetail!.externalLink!:"http://${widget.postDetail!.externalLink!}"),):SizedBox(),
                    widget.postDetail!.externalLink!.isURL?Expanded(child: Container()):SizedBox(),
                    VerticalTile(icon: Images.share, title: AppData().language!.share,onTap: () async {
                      int length=widget.postDetail!.description!.length;
                        String url = widget.postDetail!.postPicture!;
                        final _url = Uri.parse(url);
                        final response = await http.get(_url);
                        final bytes = response.bodyBytes;
                        final temp = await getTemporaryDirectory();
                        final path = '${temp.path}/image.jpg';
                        File(path).writeAsBytesSync(bytes);
                      // Share.share(
                      //     "Title: "+ widget.postDetail!.title!+"\n"+
                      //         "Summary: "+widget.postDetail!.description!.substring(0,length>100?100:length>50?50:length>20?20:length)+
                      //         '\nClick to read more https://play.google.com/store/apps/details?id=com.knawnews.apps&hl=en&gl=US');
                      await Share.shareFiles([path],text: "Title: "+ widget.postDetail!.title!+"\n"+
                                  "Summary: "+widget.postDetail!.description!.substring(0,length>100?100:length>50?50:length>20?20:length)+
                          "\nClick to read more https://knawnews.com/"
                      );
                    }),
                    Expanded(child: Container()),
                    PopupMenuButton(
                        child: Center(
                            child:  Icon(Icons.more_vert,size:20,color: Colors.grey.withOpacity(0.5),)
                        ),
                        onSelected: (value){

                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(

                            padding:const EdgeInsets.symmetric(vertical: 0,horizontal: 8),
                            height:20,
                            child: InkWell(
                              onTap: () => Get.dialog(ReportDialog(postDetail: widget.postDetail)),
                              child: Text(AppData().language!.reportThread,
                                style: openSansRegular.copyWith(fontSize: Dimensions.fontSizeDefault),),
                            ),
                          ),
                        ]
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Comments on post
        isComment?Container(child: CommentScreen(postDetail: widget.postDetail,)):SizedBox()
      ],
    );
  }
  void translate() async {
    var translation=await widget.postDetail!.title!.translate(to: AppData().language!.languageCode);
    var translator=await widget.postDetail!.description!.translate(to: AppData().language!.languageCode);
    if(mounted){
      widget.postDetail!.title=translation.text;
      widget.postDetail!.description=translator.text;
      setState(() {});
    }
  }
  Future<void> bookmarkPost() async {
    openLoadingDialog(context, "Loading");
    var response;
    response = await DioService.post('bookmark_news_post', {
      "newsPostId" : widget.postDetail!.newsPostId,
      "usersId" : AppData().userdetail!.usersId
    });
    if(response['status']=='success'){
      //print(postDetail![0].toJson());
      widget.postDetail!.isBookmarked=="true"?widget.postDetail!.isBookmarked="false":widget.postDetail!.isBookmarked="true";
      Navigator.pop(context);
      setState(() {

      });
      //showCustomSnackBar(response['data'],isError: false);
    }
    else{
      Navigator.pop(context);
      setState(() {

      });
      //showCustomSnackBar(response['message']);

    }
  }
  Future<void> happyReact() async {
    openLoadingDialog(context, "Loading");
    var response;
    response = await DioService.post('react_happy', {
      "newsPostId" : widget.postDetail!.newsPostId,
      "usersId" : AppData().userdetail!.usersId
    });
    if(response['status']=='success'){
      //print(postDetail![0].toJson());
      widget.postDetail!.isHappyReacted!?widget.postDetail!.happyReactions=(widget.postDetail!.happyReactions!-1):widget.postDetail!.happyReactions=(widget.postDetail!.happyReactions!+1);
      widget.postDetail!.isHappyReacted!?widget.postDetail!.isHappyReacted=false:widget.postDetail!.isHappyReacted=true;
      Navigator.pop(context);
      setState(() {

      });
      //showCustomSnackBar(response['data'],isError: false);
    }
    else{
      Navigator.pop(context);
      setState(() {

      });
      //showCustomSnackBar(response['message']);

    }
  }

  Future<void> sadReact() async {
    openLoadingDialog(context, "Loading");
    var response;
    response = await DioService.post('react_sad', {
      "newsPostId" : widget.postDetail!.newsPostId,
      "usersId" : AppData().userdetail!.usersId
    });
    if(response['status']=='success'){
      //print(postDetail![0].toJson());
      widget.postDetail!.isSadReacted!?widget.postDetail!.sadReactions=(widget.postDetail!.sadReactions!-1):widget.postDetail!.sadReactions=(widget.postDetail!.sadReactions!+1);
      widget.postDetail!.isSadReacted!?widget.postDetail!.isSadReacted=false:widget.postDetail!.isSadReacted=true;
      Navigator.pop(context);
      setState(() {

      });
      //showCustomSnackBar(response['data'],isError: false);
    }
    else{
      Navigator.pop(context);
      setState(() {

      });
      //showCustomSnackBar(response['message']);

    }
  }
  Future<void> likeOpinion() async {
    openLoadingDialog(context, "Loading");
    var response;
    response = await DioService.post('like_opinion', {
      "newsPostId" : widget.postDetail!.newsPostId,
      "usersId" : AppData().userdetail!.usersId
    });
    if(response['status']=='success'){
      //print(postDetail![0].toJson());
      widget.postDetail!.isHappyReacted!?widget.postDetail!.happyReactions=(widget.postDetail!.happyReactions!-1):widget.postDetail!.happyReactions=(widget.postDetail!.happyReactions!+1);
      widget.postDetail!.isHappyReacted!?widget.postDetail!.isHappyReacted=false:widget.postDetail!.isHappyReacted=true;
      Navigator.pop(context);
      setState(() {

      });
      //showCustomSnackBar(response['data'],isError: false);
    }
    else{
      Navigator.pop(context);
      setState(() {

      });
      //showCustomSnackBar(response['message']);

    }
  }
  Future<void> dislikeOpinion() async {
    openLoadingDialog(context, "Loading");
    var response;
    response = await DioService.post('dislike_opinion', {
      "newsPostId" : widget.postDetail!.newsPostId,
      "usersId" : AppData().userdetail!.usersId
    });
    if(response['status']=='success'){
      //print(postDetail![0].toJson());
      widget.postDetail!.isSadReacted!?widget.postDetail!.sadReactions=(widget.postDetail!.sadReactions!-1):widget.postDetail!.sadReactions=(widget.postDetail!.sadReactions!+1);
      widget.postDetail!.isSadReacted!?widget.postDetail!.isSadReacted=false:widget.postDetail!.isSadReacted=true;
      Navigator.pop(context);
      setState(() {

      });
      //showCustomSnackBar(response['data'],isError: false);
    }
    else{
      Navigator.pop(context);
      setState(() {

      });
      //showCustomSnackBar(response['message']);

    }
  }
  Future<void> viewPost() async {
    //openLoadingDialog(context, "Loading");
    var response;

    response = await DioService.post('view_post', {
      "usersId" : AppData().userdetail!.usersId,
      "newsPostId" : widget.postDetail!.newsPostId
    });
    if(response['status']=='success'){
      //Navigator.pop(context);
      setState(() {

      });
      //showCustomSnackBar(response['data'],isError: false);
    }
    else{
      //Navigator.pop(context);
      setState(() {

      });
      //showCustomSnackBar(response['message']);

    }
  }
}
