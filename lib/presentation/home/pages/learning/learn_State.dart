import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myecomerceapp/presentation/home/pages/learning/data/data.dart';

class LearnStatePage extends StatefulWidget {
  const LearnStatePage({super.key});

  @override
  State<LearnStatePage> createState() => _LearnStateState();
}

class _LearnStateState extends State<LearnStatePage> {
  @override
  Widget build(BuildContext context) {
    final title = "Learning Cubit and state";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(color: Colors.black, fontSize: 20)),
            SizedBox(height: 10),
            _TextFieldForm(),
            SizedBox(height: 100),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Text(
                        products[index].id.toString(),
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      Text(
                        products[index].name,
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      SizedBox(width: 10),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextFieldForm extends StatefulWidget {
  const _TextFieldForm();

  @override
  State<_TextFieldForm> createState() => _TextFieldFormState();
}

class _TextFieldFormState extends State<_TextFieldForm> {
  String pdName = '';
  int pdPrice = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.text,
            onChanged: (value) {
              setState(() {
                pdName = value;
              });
            },
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black, fontSize: 20),
            decoration: InputDecoration(
              labelText: "Product Name",
              hintText: "Enter Product Name",
              enabledBorder: OutlineInputBorder(),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                pdPrice = int.tryParse(value) ?? 0;
              });
            },
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black, fontSize: 20),
            decoration: InputDecoration(
              labelText: "Product Price",
              hintText: "Enter Product Price",
              enabledBorder: OutlineInputBorder(),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.fromLTRB(50, 15, 50, 15),
            ),
            onPressed: () {
              setState(() {
                products.add(Product(id: products.length + 1, name: pdName, price: pdPrice));
                pdName = '';
                pdPrice = 0;
                print(products.length);
              });
            },
            child: Text("Save"),
          ),
          SizedBox(height: 30),
          Text(
            "this is name : $pdName",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          Text(
            "this is price : $pdPrice",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
