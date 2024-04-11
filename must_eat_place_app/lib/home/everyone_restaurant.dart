import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:must_eat_place_app/detail/everyone_detail_page.dart';
import 'package:must_eat_place_app/insert/everyone_insert_page.dart';
import 'package:must_eat_place_app/model/firebase_review_list.dart';
import 'package:must_eat_place_app/update/everyone_update_page.dart';
import 'package:url_launcher/url_launcher.dart';

class EveryoneRestaurant extends StatefulWidget {
  const EveryoneRestaurant({super.key});

  @override
  State<EveryoneRestaurant> createState() => _EveryoneRestaurantState();
}

class _EveryoneRestaurantState extends State<EveryoneRestaurant> {
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
                  '모두의 ',
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
                  Get.to(const EveryoneInsertPage());
                },
                icon: const Icon(Icons.add_circle_outline)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('musteatplace')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final musteatplace = snapshot.data!.docs;
                return ListView(
                    children: musteatplace
                        .map((e) => buildEatListWidget(e))
                        .toList());
              } else {
                return const Center(
                  child: Text('저장된 맛집 목록이 없습니다!'),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // --

  Widget buildEatListWidget(doc) {
    final eatlist = FireBaseReviewList(
      id: doc.id,
      name: doc['name'],
      phone: doc['phone'],
      lat: doc['lat'],
      lng: doc['lng'],
      image: doc['image'],
      estimate: doc['estimate'],
      initdate: doc['initdate'],
    );

    return Slidable(
      startActionPane: ActionPane(motion: const DrawerMotion(), children: [
        SlidableAction(
          onPressed: (context) {
            Get.to(const EveryoneUpdatePage(), arguments: eatlist);
          },
          icon: Icons.edit,
          label: '수정하기',
          backgroundColor: Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
      ]),
      endActionPane: ActionPane(motion: const DrawerMotion(), children: [
        SlidableAction(
          onPressed: (context) {
            FirebaseFirestore.instance
                .collection('musteatplace')
                .doc(doc.id)
                .delete();
            _deleteDialog();
          },
          icon: Icons.delete_outline,
          label: '삭제하기',
          backgroundColor: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
      ]),
      child: GestureDetector(
        onTap: () => Get.to(const EveryoneDetailPage(), arguments: eatlist),
        child: Card(
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                height: MediaQuery.of(context).size.height / 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    eatlist.image!,
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
                        eatlist.name,
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
                          width: MediaQuery.of(context).size.width / 3 * 1.4,
                          height: MediaQuery.of(context).size.height / 16,
                          child: Text(
                            eatlist.estimate,
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
                          width: MediaQuery.of(context).size.width / 5.5,
                        ),
                        TextButton.icon(
                          onPressed: () {
                            callActionSheet(eatlist.phone);
                          },
                          icon: const Icon(Icons.call),
                          label: Text(eatlist.phone),
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

  _deleteDialog() {
    Get.defaultDialog(title: '완료', middleText: '맛집 리스트가 삭제되었습니다.', actions: [
      ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('확인'))
    ]);
  }
}
