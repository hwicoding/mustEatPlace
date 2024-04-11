import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:must_eat_place_app/detail/our_detail_page.dart';
import 'package:must_eat_place_app/insert/our_insert_page.dart';
import 'package:must_eat_place_app/update/our_update_page.dart';
import 'package:url_launcher/url_launcher.dart';

class OurRestaurant extends StatefulWidget {
  const OurRestaurant({super.key});

  @override
  State<OurRestaurant> createState() => _OurRestaurantState();
}

class _OurRestaurantState extends State<OurRestaurant> {
  late List eatlist;

  @override
  void initState() {
    eatlist = [];
    super.initState();
    getJSPData();
  }

  getJSPData() async {
    var url =
        Uri.parse('http://localhost:8080/Flutter/JSP/select_musteat_list.jsp');
    var response = await http.readBytes(url);
    List result = json.decode(utf8.decode(response))['eatlist'];
    eatlist.addAll(result);
    setState(() {});
  }

  reloadData() {
    eatlist.clear();
    getJSPData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "우리만의 ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '맛집',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 168, 14, 3)),
                ),
                Text(
                  ' 리스트',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: IconButton(
                onPressed: () {
                  Get.to(const OurInsertPage())!.then((value) => setState(() {
                        reloadData();
                      }));
                },
                icon: const Icon(Icons.add_circle_outline)),
          )
        ],
      ),
      body: ListView.builder(
          itemCount: eatlist.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
              child: Slidable(
                startActionPane:
                    ActionPane(motion: const DrawerMotion(), children: [
                  SlidableAction(
                    onPressed: (context) {
                      Get.to(const OurUpdatePage(), arguments: eatlist[index])!
                          .then((value) => reloadData());
                    },
                    icon: Icons.edit,
                    label: '수정하기',
                    backgroundColor: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ]),
                endActionPane:
                    ActionPane(motion: const DrawerMotion(), children: [
                  SlidableAction(
                    onPressed: (context) async {
                      await sendDeleteJSP(index);
                      reloadData();
                    },
                    icon: Icons.delete_outline,
                    label: '삭제하기',
                    backgroundColor: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ]),
                child: GestureDetector(
                  onTap: () =>
                      Get.to(const OurDetailPage(), arguments: eatlist[index]),
                  child: Card(
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          height: MediaQuery.of(context).size.height / 6,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'http://localhost:8080/Flutter/MustEatPlace/image/${eatlist[index]['image']}',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3 * 1.78,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  eatlist[index]['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width /
                                        3 *
                                        1.4,
                                    height:
                                        MediaQuery.of(context).size.height / 16,
                                    child: Text(
                                      eatlist[index]['estimate'],
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 5.5,
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      callActionSheet(eatlist[index]['phone']);
                                    },
                                    icon: const Icon(Icons.call),
                                    label: Text(eatlist[index]['phone']),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  showDeleteDialog() {
    Get.defaultDialog(title: '완료', middleText: '맛집 리스트가 삭제되었습니다.', actions: [
      ElevatedButton(
          onPressed: () {
            Get.back();
            setState(() {});
          },
          child: const Text('확인'))
    ]);
  }

  sendDeleteJSP(index) async {
    String seq = eatlist[index]['seq'];

    var url = Uri.parse(
        'http://localhost:8080/Flutter/MustEatPlace/delete_musteat_list.jsp?seq=$seq');
    var response = await http.get(url);
    var convert = json.decode(utf8.decode(response.bodyBytes));

    var result = convert['result'];
    result == 'OK' ? showDeleteDialog() : _errorDelteSnackBar();
  }

  _errorDelteSnackBar() {
    Get.snackbar(
      '오류 발생',
      '삭제 중 오류가 발생하였습니다. 다시 시도해주세요.',
      borderColor: Colors.red,
      colorText: Colors.white,
    );
  }

  callActionSheet(phone) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
          title: const Text(
            '통화 연결',
            style: TextStyle(),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                final Uri call = Uri(path: 'tel:$phone');
                if (await canLaunchUrl(call)) {
                  await launchUrl(call);
                }
              },
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [const Icon(Icons.call), Text(' $phone')],
                ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
              onPressed: () => Get.back(),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.red, fontSize: 20),
              ))),
    );
  }
}
