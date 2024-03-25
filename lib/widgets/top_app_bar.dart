import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget {
  final List<Tab>? tabs;

  const TopAppBar({Key? key, this.tabs}) : super(key: key);

  _openSearchPage(BuildContext context) {
    Navigator.pushNamed(context, '/search');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          child: TextButton(
            onPressed: () => _openSearchPage(context),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white.withOpacity(0.2)),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 24),
                      child: Text(
                        "Search",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontFamily: 'Lato',
                            fontSize: 17),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 24),
                      child: Icon(
                        Icons.search,
                        size: 28,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        TabBar(
          tabs: tabs!,
        ),
      ],
    );
  }
}
