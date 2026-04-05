import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  _titleText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _titleText("User Name"),
                    const SizedBox(width: 100),
                    ClipOval(
                      child: Image.asset(
                        "assets/images/logo-with-duo.png",
                        height: 120,
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.grey.shade500),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _titleText("Sobre"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Card(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 80,
                            width: 170,
                            child: const Text("hello"),
                          ),
                        ),
                        Card(
                          child: SizedBox(
                            height: 80,
                            width: 170,
                            child: const ListTile(
                                leading: Icon(
                                  Icons.cloud_circle,
                                  color: Colors.amber,
                                ),
                                title: Text(
                                  "4600",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                )),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Card(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 80,
                            width: 170,
                            child: const Text("hello"),
                          ),
                        ),
                        Card(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 80,
                            width: 170,
                            child: const Text("hello"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _titleText("Amigos"),
                        const Text("ADICIONAR AMIGOS", style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: Colors.lightBlue),),
                      ],
                    ),
                    Card(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 80,
                        width: 170,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
