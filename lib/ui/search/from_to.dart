import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:latlong/latlong.dart';
import 'dart:core';
import 'next_page.dart';
import 'package:translator/translator.dart';

/// I am really sorry for the unordered code without proper documentations...
/// please suggest me some measures in writing the code effectively n properly

class SearchPaage extends StatelessWidget {
  final bool enable;
  SearchPaage(this.enable);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Soup(enable),
    );
  }
}

class Soup extends StatelessWidget {
  final bool enable;
  Soup(this.enable);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make your Safe Route'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white70,
      body: Container(
        child: SearchPage(enable),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  final bool enable;
  SearchPage(this.enable);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _textController1 = TextEditingController();
  final _textController2 = TextEditingController();
  final translator = GoogleTranslator();
  bool enable;

  @override
  void initState() {
    enable = widget.enable;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FlutterMap(
            options:
                new MapOptions(center: new LatLng(13.00, 80.17), minZoom: 6.0),
            layers: [
              new TileLayerOptions(
                  urlTemplate:
                      "https://api.mapbox.com/styles/v1/ammaamma/ck98c24q356631ip7xkk1vkq0/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg",
                  additionalOptions: {
                    'accessToken':
                        'pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg',
                    'id': 'mapbox.mapbox-streets-v7'
                  }),
            ]),
        Positioned(
          top: 50.0,
          right: 15.0,
          left: 15.0,
          child: Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey,
                    offset: Offset(1.0, 5.0),
                    blurRadius: 10,
                    spreadRadius: 3)
              ],
            ),
            child: CustomTextField(
              textController: _textController1,
              hintText: enable ? "From" : "புறப்படும் இடம்",
              prefixIcon: Icon(
                Icons.my_location,
                color: Colors.deepPurple,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapBoxAutoCompleteWidget(
                      apiKey:
                          "pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg",
                      hint: "From",
                      onSelect: (place) {
                        //String src = place.placeName.substring(0, 15);
                        String src = place.placeName;
                        print(src);
                        List k = src.split(',');
                        _textController1.text = k[0];
                        Navigator.pop(context);
                      },
                      limit: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 105.0,
          right: 15.0,
          left: 15.0,
          child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1.0, 5.0),
                      blurRadius: 10,
                      spreadRadius: 3)
                ],
              ),
              child: CustomTextField(
                textController: _textController2,
                hintText: enable ? "To" : "சேரும் இடம்",
                prefixIcon: Icon(
                  Icons.local_taxi,
                  color: Colors.deepPurple,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapBoxAutoCompleteWidget(
                        apiKey:
                            "pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg",
                        hint: 'To',
                        onSelect: (place) {
                          String destination = place.placeName;
                          print(destination);
                          List k = destination.split(',');
                          _textController2.text = k[0];
                          Navigator.pop(context);
                        },
                        limit: 10,
                      ),
                    ),
                  );
                },
              )),
        ),
        SizedBox(height: 30),
        Positioned(
          top: 165.0,
          right: 15.0,
          left: 15.0,
          child: RaisedButton(
            onPressed: () {
              var route = new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      NextPage(_textController1.text, _textController2.text));
              Navigator.of(context).push(route);
            },
            color: Colors.deepPurple,
            child: enable
                ? const Text('Find The Safest Route',
                    style: TextStyle(fontSize: 20, color: Colors.white))
                : const Text('பாதுகாப்பான பாதையைக் கண்டறியவும்',
                    style: TextStyle(fontSize: 13, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
