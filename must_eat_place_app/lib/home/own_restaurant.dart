import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:must_eat_place_app/detail/own_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../insert/own_insert_page.dart';
import '../update/own_update_page.dart';
import '../vm/db_handler.dart';

class OwnRestaurant extends StatefulWidget {
  const OwnRestaurant({super.key});

  @override
  State<OwnRestaurant> createState() => _OwnRestaurantState();
}

class _OwnRestaurantState extends State<OwnRestaurant> {
  late DatabaseHandler handler;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        title: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "나만의 ",
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
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  Get.to(const OwnInsertPage())!.then((value) {
                    setState(() {});
                  });
                },
                icon: const Icon(Icons.add_circle_outline)),
          )
        ],
      ),
      body: FutureBuilder(
        future: handler.queryReview(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                  child: Slidable(
                    startActionPane:
                        ActionPane(motion: const DrawerMotion(), children: [
                      SlidableAction(
                        onPressed: (context) {
                          Get.to(const OwnUpdatePage(),
                                  arguments: snapshot.data![index])!
                              .then((value) => setState(() {}));
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
                          _showDiaglog();
                          await handler.deleteReview(snapshot.data![index].seq);
                        },
                        icon: Icons.delete_outline,
                        label: '삭제하기',
                        backgroundColor: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ]),
                    child: GestureDetector(
                      onTap: () => Get.to(const OwnDetailPage(), arguments: [
                        snapshot.data![index].lat,
                        snapshot.data![index].long,
                        snapshot.data![index].name,
                      ]),
                      child: Card(
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              height: MediaQuery.of(context).size.height / 6,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  snapshot.data![index].image,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width / 3 * 1.78,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      snapshot.data![index].name,
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
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3 *
                                                1.4,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                16,
                                        child: Text(
                                          snapshot.data![index].estimate,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5.5,
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          callActionSheet(
                                              snapshot.data![index].phone);
                                        },
                                        icon: const Icon(Icons.call),
                                        label:
                                            Text(snapshot.data![index].phone),
                                      ),
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
              },
            );
          } else {
            return const Center(
                child: Text(
              '저장된 목록이 없습니다!',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ));
          }
        },
      ),
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

  _showDiaglog() {
    Get.defaultDialog(title: '완료', middleText: '맛집 리스트가 삭제되었습니다.', actions: [
      ElevatedButton(
          onPressed: () {
            Get.back();
            setState(() {});
          },
          child: const Text('확인'))
    ]);
  }
}
