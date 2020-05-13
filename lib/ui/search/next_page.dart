import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:xml2json/xml2json.dart';

class NextPage extends StatefulWidget {
  final String from;
  final String to;
  NextPage(this.from, this.to);

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  final myTransformer = Xml2Json();
  List<Marker> allMarkers = [];
  List<String> places = [];
  List<LatLng> route1 = [];
  //List<LatLng> saferoute1 = [];
  List<List> coordinates = [];
  List<Polyline> polyline = [];

  @override
  void initState() {
    places.add(widget.from);
    places.add(widget.to);
    fetchroute();
    super.initState();
  }

  fetchroute() async {
    try {
      final query = places[0];
      var addresses = await Geocoder.local.findAddressesFromQuery(query);
      var first = addresses.first;
      final query1 = places[1];
      var addresses1 = await Geocoder.local.findAddressesFromQuery(query1);
      var first1 = addresses1.first;
      getSafestRouteUsingApi(
        LatLng(first.coordinates.latitude, first.coordinates.longitude),
        LatLng(first1.coordinates.latitude, first1.coordinates.longitude),
      );
      allMarkers.add(
        new Marker(
          width: 45.0,
          height: 45.0,
          point: new LatLng(
              first.coordinates.latitude, first.coordinates.longitude),
          builder: (context) => new Container(
            child: IconButton(
              color: Colors.deepPurple,
              icon: Icon(Icons.location_on),
              iconSize: 45.0,
              onPressed: () {
                print(first.featureName);
              },
            ),
          ),
        ),
      );
      allMarkers.add(
        new Marker(
          width: 45.0,
          height: 45.0,
          point: new LatLng(
              first1.coordinates.latitude, first1.coordinates.longitude),
          builder: (context) => new Container(
            child: IconButton(
              color: Colors.deepPurple,
              icon: Icon(Icons.location_on),
              iconSize: 45.0,
              onPressed: () {
                print(first1.featureName);
              },
            ),
          ),
        ),
      );
    } catch (e) {
      showAlertDialog(context);
    }
  } //geocodes the input source and destination,gets the route if error,shows a dialog box

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Uh hO!"),
      content: Text("No Places Found!!"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> getSafestRouteUsingApi(LatLng start, LatLng end) async {
    double lat1 = start.latitude;
    double lng1 = start.longitude;
    double lat2 = end.latitude;
    double lng2 = end.longitude;

    Response response = await get(
        "https://ceg-maps.herokuapp.com/getRoute?st_lat=$lat1&st_lng=$lng1&e_lat=$lat2&e_lng=$lng2");
    print(response.body);
    var data = json.decode(response.body);

    List<dynamic> coordinates1 = data['route'];
    for (String i in coordinates1) {
      var a = i.split(",");
      double o = double.parse(a[0]);
      double p = double.parse(a[1]);
      route1.add(LatLng(o, p));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Make My Safest Route"),
      ),
      body: new FlutterMap(
          options: new MapOptions(
              center: new LatLng(13.0109, 80.2354), minZoom: 5.0),
          layers: [
            new TileLayerOptions(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/ammaamma/ck98c24q356631ip7xkk1vkq0/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg",
                additionalOptions: {
                  'accessToken':
                      'pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg',
                  'id': 'mapbox.mapbox-streets-v7'
                }),
            new MarkerLayerOptions(markers: allMarkers),
            new PolylineLayerOptions(polylines: [
              new Polyline(
                points: route1,
                strokeWidth: 6.0,
                color: Colors.blue,
              ),
            ]),
//            new PolylineLayerOptions(polylines: [
//              new Polyline(
//                  points: route1, strokeWidth: 6.0, color: Colors.yellow),
//            ]),
//            new PolylineLayerOptions(polylines: [
//              new Polyline(
//                  points: route2, strokeWidth: 6.0, color: Colors.pink),
//            ]),
//            new PolylineLayerOptions(polylines: polycolourlines),
          ]),
    );
  }
}
