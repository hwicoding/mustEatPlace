import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EveryoneUpdatePage extends StatefulWidget {
  const EveryoneUpdatePage({super.key});

  @override
  State<EveryoneUpdatePage> createState() => _EveryoneUpdatePageState();
}

class _EveryoneUpdatePageState extends State<EveryoneUpdatePage> {
  var argument = Get.arguments;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController estimateController;
  late double latData;
  late double longData;

  ImagePicker picker = ImagePicker();
  XFile? imageFile;
  File? imgFile;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    estimateController = TextEditingController();
    alreadyExistData();
  }

  alreadyExistData() {
    nameController.text = argument.name;
    phoneController.text = argument.phone;
    estimateController.text = argument.estimate;

    latData = argument.lat;
    longData = argument.lng;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Row(
            children: [
              Text(
                '모두의 맛집 리스트 수정',
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
                          ? Image.network(argument.image)
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
                          labelText: '맛집의 이름', border: OutlineInputBorder()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                    child: TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                          labelText: '맛집의 전화번호', border: OutlineInputBorder()),
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
                          border: OutlineInputBorder(borderSide: BorderSide()),
                        ),
                        maxLength: 50,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        _showDiaglog();
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
      imageFile = null;
    } else {
      imageFile = XFile(pickedFile.path);
      imgFile = File(imageFile!.path);
    }
    setState(() {});
  }

  _showDiaglog() {
    Get.defaultDialog(title: '확인', middleText: '정말로 수정하시겠습니까?', actions: [
      ElevatedButton(onPressed: () => Get.back(), child: const Text('취소')),
      ElevatedButton(
          onPressed: () async {
            Get.back();
            await _loadingDialog();
            String image = '';
            if (imageFile == null) {
              image = argument.image;
            } else {
              image = await preparingImage();
            }

            FirebaseFirestore.instance
                .collection('musteatplace')
                .doc(argument.id)
                .update({
              'name': nameController.text,
              'phone': phoneController.text,
              'estimate': estimateController.text,
              'image': image,
            });
            Get.back();
            updateDialog();
          },
          child: const Text('확인')),
    ]);
  }

  Future<String> preparingImage() async {
    FirebaseStorage.instance
        .ref()
        .child('musteatplaceimage')
        .child(
            '${argument.name}_${latData}_${longData}_${argument.initdate}.png')
        .delete();

    final firebaseStorage = FirebaseStorage.instance
        .ref()
        .child('musteatplaceimage')
        .child(
            '${nameController.text}_${latData}_${longData}_${argument.initdate}.png');
    await firebaseStorage.putFile(imgFile!);

    String downloadURL = await firebaseStorage.getDownloadURL();
    return downloadURL;
  }

  updateDialog() {
    Get.defaultDialog(title: '완료', middleText: '맛집 리스트가 수정되었습니다.', actions: [
      ElevatedButton(
          onPressed: () async {
            Get.back();
            Get.back();
          },
          child: const Text('확인'))
    ]);
  }

  _loadingDialog() {
    Get.defaultDialog(
      barrierDismissible: false,
      title: '안내',
      middleText: '저장 중 입니다. 잠시만 기다려주세요.',
    );
  }
}
