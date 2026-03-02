import 'package:flutter/material.dart';
import 'package:myecomerceapp/widgets/Appbar/homepgeApp_widget.dart';
import 'package:myecomerceapp/widgets/searchbar/searchbar.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(228, 0, 64, 84),
      appBar: appBarWidget(),
      body: const bodyHomePage(),
    );
  }
}

class bodyHomePage extends StatefulWidget {
  const bodyHomePage({super.key});

  @override
  State<bodyHomePage> createState() => _StatehomePage();
}

class _StatehomePage extends State<bodyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            children: [
              const Expanded(child: Searchbar()),
              const SizedBox(width: 10),
              _iconSearchWidget(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _promotionWidget(),
      ],
    );
  }
}

// Icoinsearchbar Widget
Widget _iconSearchWidget() {
  return (Container(
    child: Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.search_outlined, color: Colors.white, size: 35),
        ),
      ],
    ),
  ));
}

Widget _promotionWidget() {
  final imagelongShow = [
    "assets/images/imagelong1.png",
    "assets/images/imagelong2.png",
    "assets/images/imagelong3.png",
    "assets/images/imagelong4.png",
  ];

  return (Container(
    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 10, right: 10),

          child: const Expanded(
            child: Text(
              "Promotoin",
              textAlign: TextAlign.start,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.white),
            color: const Color.fromARGB(97, 28, 44, 59),
            borderRadius: BorderRadius.circular(10),
          ),
          height: 200,

          child: Row(
            children: imagelongShow.map((imagePath) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  ));
}
