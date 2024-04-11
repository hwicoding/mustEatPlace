import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class OurInsertPage extends StatefulWidget {
  const OurInsertPage({super.key});

  @override
  State<OurInsertPage> createState() => _OurInsertPageState();
}

class _OurInsertPageState extends State<OurInsertPage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController estimateController;

  late double latData;
  late double longData;

  ImagePicker picker = ImagePicker();
  XFile? galleryImageFile;

  @override
  void initState() {
    super.initState();
    latData = 0;
    longData = 0;
    nameController = TextEditingController();
    phoneController = TextEditingController();
    estimateController = TextEditingController();
    checkLocationPermission();
  }

  checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      getCurrentLocation();
    }
  }

  getCurrentLocation() async {
    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((position) {
      latData = position.latitude;
      longData = position.longitude;

      setState(() {});
    }).catchError((e) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Row(
            children: [
              Text(
                '우리들의 맛집 리스트 추가',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: OutlinedButton(
                        onPressed: () {
                          getImageFromDevice(ImageSource.gallery);
                        },
                        child: const Text('사진 추가하기')),
                  ),
                  Container(
                    // width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 6,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 188, 186, 186),
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
                      height: 150,
                      child: galleryImageFile == null
                          ? Center(
                              child: Text(
                              '이미지를 선택해 주세요!',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                            ))
                          : Image.file(File(galleryImageFile!.path)),
                    ),
                  ),
                  Padding(
                    // 위치 (위도 경도)
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                          child: Row(
                            children: [
                              const Text('위도 : '),
                              Text('$latData'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                          child: Row(
                            children: [
                              const Text('경도 : '),
                              Text('$longData'),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    // 이름 textField
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: '맛집의 이름', border: OutlineInputBorder()),
                    ),
                  ),
                  Padding(
                    // 전화번호 textField
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                    child: TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                          labelText: '맛집의 전화번호', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  Padding(
                    // 평가 textField
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                    child: SizedBox(
                      width: 400,
                      height: 150,
                      child: TextField(
                        controller: estimateController,
                        decoration: const InputDecoration(
                          labelText: '나만의 평가',
                          border: OutlineInputBorder(borderSide: BorderSide()),
                        ),
                        maxLength: 50,
                        // keyboardType: TextInputType.multiline,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (galleryImageFile == null) {
                          checkImage();
                          return;
                        }
                        dbInsertAction();
                      },
                      child: const Text('저장하기'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  getImageFromDevice(imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      galleryImageFile = null;
    } else {
      galleryImageFile = XFile(pickedFile.path);
    }
    setState(() {});
  }

  showDiaglog() {
    Get.defaultDialog(
        title: '완료',
        middleText: '맛집 리스트가 추가되었습니다.',
        barrierDismissible: false,
        actions: [
          ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('확인'))
        ]);
  }

  dbInsertAction() async {
    String name = nameController.text;
    String phone = phoneController.text;
    String estimate = estimateController.text;
    String initdate = DateTime.now().toString();

    String result = '';

    String time = DateTime.now().toString();

    result = await uploadImage(time);

    if (result == 'success') {
      // 이미지 업로드 성공
      result = '';

      String imageName =
          '${nameController.text}_${latData}_${longData}_$time.jpg';

      var url = Uri.parse(
          'http://localhost:8080/Flutter/MustEatPlace/insert_musteat_list.jsp?name=$name&phone=$phone&lat=$latData&lng=$longData&image=$imageName&estimate=$estimate&initdate=$initdate');
      var response = await http.get(url);
      var convert = await json.decode(utf8.decode(response.bodyBytes));
      result = convert['result'];

      if (result == 'OK') {
        showDiaglog();
      } else {
        _errorInsertSnackBar();
      }
    } else {
      _errorImageSnackBar();
    }
  }

  Future<String> uploadImage(time) async {
    dio.Dio dioImage = dio.Dio();

    String imageName =
        '${nameController.text}_${latData}_${longData}_$time.jpg';

    final formData = dio.FormData.fromMap({
      'file': await dio.MultipartFile.fromFile(galleryImageFile!.path,
          filename: imageName),
    });

    dio.Response response = await dioImage.post(
        'http://localhost:8080/Flutter/MustEatPlace/upload_image.jsp',
        data: formData);

    final responseData = jsonDecode(response.data);
    final result = responseData['result'];

    return result;
  }

  _errorImageSnackBar() {
    Get.snackbar(
      '오류 발생',
      '이미지 업로드 중 오류가 발생하였습니다. 다시 시도해주세요.',
      borderColor: Colors.red,
      colorText: Colors.white,
    );
  }

  _errorInsertSnackBar() {
    Get.snackbar(
      '오류 발생',
      '이미지 업로드 중 오류가 발생하였습니다. 다시 시도해주세요.',
      borderColor: Colors.red,
      colorText: Colors.white,
    );
  }

  checkImage() {
    Get.defaultDialog(
        title: '경고',
        middleText: '이미지를 선택해 주세요!',
        barrierDismissible: false,
        actions: [
          ElevatedButton(onPressed: () => Get.back(), child: const Text('확인'))
        ]);
  }
}
