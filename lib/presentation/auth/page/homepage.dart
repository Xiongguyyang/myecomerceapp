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
    return Row(
      children: [
        const Expanded(child: Searchbar()),
        SizedBox(width: 10),
        _iconSearchWidget(),
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
          icon: Icon(Icons.search_off_sharp, color: Colors.white, size: 35,),
        ),
      ],
    ),
  ));
}
