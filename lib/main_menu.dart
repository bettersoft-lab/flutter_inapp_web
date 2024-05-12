import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:test_webview/web.dart';


class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.title});

  final String title;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Menu",style: TextStyle(color: Colors.white),), backgroundColor: Colors.pinkAccent,),
        body: Container(
          width: double.infinity,
          color: Colors.white,
          child: Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                    ),
                    onPressed: () {
                        gotoWebView("https://dev-modules.bsbiggie.com/frontend-about-biggie/?card_id=1&token=xxxx");
                    },
                    icon: const Icon(Icons.account_circle_outlined),
                    label: const Text("Profile"),
                  )
                ],
              ),
          ),
        ),
      ),
    );
  }

  Future<void> gotoWebView(String? link_url) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewPage( link_url: link_url)),
    );
  }
}