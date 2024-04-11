import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EveryoneInsertPage extends StatefulWidget {
  const EveryoneInsertPage({super.key});

  @override
  State<EveryoneInsertPage> createState() => _EveryoneInsertPageState();
}

class _EveryoneInsertPageState extends State<EveryoneInsertPage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController estimateController;
  late double latData;
  late double longData;
  late bool _isloading;

  ImagePicker picker = ImagePicker();
  XFile? imageFile;
  File? imgFile;

  @override
  void initState() {
    super.initState();
    latData = 0;
    longData = 0;
    nameController = TextEditingController();
    phoneController = TextEditingController();
    estimateController = TextEditingController();
    checkLocationPermission();

    _isloading = false;
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
                '       모두의 ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '맛집 ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 168, 14, 3),
                ),
              ),
              Text(
                '리스트 추가하기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
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
                        height: MediaQuery.of(context).size.height / 6,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(255, 188, 186, 186),
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3 * 2,
                          height: 150,
                          child: imageFile == null
                              ? Center(
                                  child: Text(
                                  '이미지를 선택해 주세요!',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer),
                                ))
                              : Image.file(File(imageFile!.path)),
                        ),
                      ),
                      Padding(
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
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                              labelText: '맛집의 이름',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                        child: TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                              labelText: '맛집의 전화번호',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                        child: SizedBox(
                          width: 400,
                          height: 150,
                          child: TextField(
                            controller: estimateController,
                            decoration: const InputDecoration(
                              labelText: '나만의 평가',
                              border:
                                  OutlineInputBorder(borderSide: BorderSide()),
                            ),
                            maxLength: 50,
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            insertFirebase();
                          },
                          child: const Text('저장하기')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getImageFromDevice(imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      imageFile = null;
    } else {
      imageFile = XFile(pickedFile.path);
      imgFile = File(imageFile!.path);
    }
    setState(() {});
  }

  _showDiaglog() {
    Get.defaultDialog(title: '완료', middleText: '맛집 리스트가 추가되었습니다.', actions: [
      ElevatedButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: const Text('확인'))
    ]);
  }

  insertFirebase() async {
    setState(() {
      _isloading = true;
      _loadingDialog();
    });

    String time = DateTime.now().toString();
    String imagePath = await preparingImage(time);
    await FirebaseFirestore.instance.collection('musteatplace').add({
      'name': nameController.text,
      'phone': phoneController.text,
      'lat': latData,
      'lng': longData,
      'image': imagePath,
      'initdate': time,
      'estimate': estimateController.text
    });

    setState(() {
      _isloading = false;
      Get.back();
    });

    _showDiaglog();
  }

  Future<String> preparingImage(String time) async {
    final firebaseStorage = FirebaseStorage.instance
        .ref()
        .child('musteatplaceimage')
        .child('${nameController.text}_${latData}_${longData}_$time.png');

    await firebaseStorage.putFile(imgFile!);
    String downloadURL = await firebaseStorage.getDownloadURL();
    return downloadURL;
  }

  _loadingDialog() {
    if (_isloading) {
      Get.defaultDialog(
        barrierDismissible: false,
        title: '안내',
        middleText: '저장 중 입니다. 잠시만 기다려주세요.',
      );
    }
  }
}
