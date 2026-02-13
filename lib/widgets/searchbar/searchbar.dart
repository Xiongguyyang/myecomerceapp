import 'package:flutter/material.dart';

class Searchbar extends StatefulWidget {
  const Searchbar({super.key});

  @override
  State<Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SearchBar(
        backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(159, 190, 190, 190)),
        textStyle: WidgetStatePropertyAll(const TextStyle(color: Colors.white)),
        hintText: 'Search...',
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)),
        constraints: BoxConstraints(minHeight: 50),
      ),
    );
  }
}


