import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:madhu_farma/Helper/Colors.dart';
import 'package:madhu_farma/Helper/CustomButton.dart';
import 'package:madhu_farma/Helper/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ApiPath/Api.dart';
import '../Helper/Appbar.dart';

class PunchInScreen extends StatefulWidget {
  const PunchInScreen({Key? key}) : super(key: key);

  @override
  State<PunchInScreen> createState() => _PunchInScreenState();
}

class _PunchInScreenState extends State<PunchInScreen> {
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Choose Image Source'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, ImageSource.camera);
              },
              child: Text('Camera'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, ImageSource.gallery);
              },
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );

    if (source != null) {
      final XFile? image = await _picker.pickImage(source: source);

      setState(() {
        _selectedImage = image;
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    geUserId();
    convertDateTimeDisplay();
  }
  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
  String? formattedMonth ;
  var dateFormate;
  String? formattedDate;
  String? timeData;
  convertDateTimeDisplay() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    formattedDate = formatter.format(now);
    timeData = DateFormat("hh:mm a").format(DateTime.now());
    formattedMonth = '${_twoDigits(now.month)}';
  }
bool done =  false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: colors.grad1Color,
      appBar: customAppBar(
        context: context,
        text: getTranslated(context, "PUNCH_IN_/_OUT"),
        isTrue: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        // padding: EdgeInsets.symmetric(
        //     horizontal: MediaQuery.of(context).size.width * 0.2),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 140,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // shape: BoxShape.circle,
                  image: _selectedImage != null
                      ? DecorationImage(
                    image: FileImage(File(_selectedImage!.path)),
                    fit: BoxFit.cover,
                  )
                      : null,
                  border: Border.all(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                child: _selectedImage == null
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text('${timeData}'),
            SizedBox(
              height: 10,
            ),

            Btn(
              height: 50,
              width: 150,
              title: isLoading == true ? getTranslated(context, "PLEASE"): checkStatus == "present"  ?  getTranslated(context, "PUNCH_OUT"):getTranslated(context, "PUNCH_IN"),
              onPress: (){
                if(done == false){
                  addPunchInApi();
                }else{
                  addPunchOutApi();
                }

            },),

            SizedBox(
              height: 50,
            ),
            // Text(
            //   'Save Successfully',
            //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            // ),
          ],
        ),
      ),
    );
  }

  String? userId ;
  geUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId  =  prefs.getString('userId');
    setState(() {});
  }
bool isLoading =  false;

  String? checkStatus;
  int? punChID;
  Future<void> addPunchInApi() async {
    setState(() {
      isLoading = true;
    });
    var parameter = {
      'user_id':userId,
      'date':formattedDate,
      'in_time':timeData,
      'month':formattedMonth,
      'status': 'present'
    };
    apiBaseHelper.postAPICall(Uri.parse(ApiService.punchIn), parameter).then((getData) async {
      checkStatus = getData['data']['status'];
      punChID = getData['punch_id'];
       setState(() {
             isLoading = false;
            });
        setState(() {
          Fluttertoast.showToast(msg: "${getData['message']}");
        //  Navigator.pop(context);
        });

      setState(() {
        isLoading = false;
      });
    });
  }


  Future<void> addPunchOutApi() async {
    setState(() {
      isLoading = true;
    });
    var parameter = {
      'punch_id':punChID,
      'out_time':timeData
    };
    apiBaseHelper.postAPICall(Uri.parse(ApiService.punchOut), parameter).then((getData) async {
      checkStatus = getData['data']['status'];
      setState(() {
        isLoading = false;
      });
      setState(() {
        Fluttertoast.showToast(msg: "${getData['message']}");
        //  Navigator.pop(context);
      });

      setState(() {
        isLoading = false;
      });
    });
  }
}

