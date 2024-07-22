import 'package:flutter/material.dart';

import 'home/everyone_restaurant.dart';
import 'home/our_restaurant.dart';
import 'home/own_restaurant.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        children: const [
          OwnRestaurant(),
          OurRestaurant(),
          EveryoneRestaurant(),
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: TabBar(
          controller: tabController,
          indicatorPadding: const EdgeInsets.all(2),
          tabs: const [
            Tab(
              icon: Icon(Icons.food_bank),
              text: '나만의 맛집',
            ),
            Tab(
              icon: Icon(Icons.food_bank),
              text: '우리만의 맛집',
            ),
            Tab(
              icon: Icon(Icons.food_bank),
              text: '모두의 맛집',
            ),
          ],
        ),
      ),
    );
  }
}
