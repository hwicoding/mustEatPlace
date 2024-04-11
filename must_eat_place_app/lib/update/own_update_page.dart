import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_eat_place_app/model/sqlite_review_list.dart';

import '../vm/db_handler.dart';

class OwnUpdatePage extends StatefulWidget {
  const OwnUpdatePage({super.key});

  @override
  State<OwnUpdatePage> createState() => _OwnUpdatePageState();
}

class _OwnUpdatePageState extends State<OwnUpdatePage> {
  SQLiteReviewList argument = Get.arguments;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController estimateController;
  late DatabaseHandler handler;
  late double latData; // 위도
  late double longData; // 경도

  // Gallery에서 사진 가져오기
  ImagePicker picker = ImagePicker();
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    estimateController = TextEditingController();
    handler = DatabaseHandler();

    alreadyExistData();
  }

  alreadyExistData() {
    nameController.text = argument.name;
    phoneController.text = argument.phone;
    estimateController.text = argument.estimate;

    latData = argument.lat;
    longData = argument.long;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Row(
            children: [
              Text(
                '       나만의 ',
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
                      child: imageFile == null
                          ? Image.memory(argument.image)
                          : Image.file(File(imageFile!.path)),
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
    }
    setState(() {});
  }

  _showDiaglog() {
    Get.defaultDialog(title: '확인', middleText: '정말로 수정하시겠습니까?', actions: [
      ElevatedButton(onPressed: () => Get.back(), child: const Text('취소')),
      ElevatedButton(
          onPressed: () async {
            await handler.updateReview(SQLiteReviewList(
                seq: argument.seq,
                name: nameController.text,
                phone: phoneController.text,
                lat: latData,
                long: longData,
                image: imageFile == null
                    ? argument.image
                    : await imageFile!.readAsBytes(),
                estimate: estimateController.text,
                initdate: DateTime.now().toString()));
            Get.back();
            updateDialog();
          },
          child: const Text('확인')),
    ]);
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
}
