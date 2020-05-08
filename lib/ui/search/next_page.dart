import 'dart:math';
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
import 'package:poly/poly.dart' as plygn;

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
  List<LatLng> route2 = [];
  List<LatLng> saferoute = [];
  List<LatLng> subsaferoute = [];
  List<LatLng> subsubsaferoute = [];
  List<LatLng> finalist = [];
  List<LatLng> saferoute1 = [];
  List<LatLng> presaferoute = [];
  List<LatLng> sufsaferoute = [];
  List<LatLng> finalistsafe = [];
  List<List> coords = [];
  List<Polyline> polycolourlines = [];
  Map<LatLng, int> dangerpoints1 = {};
  Map<LatLng, int> dangerpoints2 = {};

  @override
  void initState() {
    places.add(widget.from);
    places.add(widget.to);
    getPolygons();
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
      getSafestRoute(
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

  Future<void> apisafe(LatLng startingpt, LatLng endingpt) async {
    finalistsafe.clear();
    double start_lat = startingpt.latitude;
    double start_lng = startingpt.longitude;
    double end_lat = endingpt.latitude;
    double end_lng = endingpt.longitude;

    String accessKey =
        'pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg';

    //This gives the json response of the route between 2 points
    Response response = await get(
        "https://api.mapbox.com/directions/v5/mapbox/driving/$start_lng,$start_lat;$end_lng,$end_lat?"
        "geometries=geojson"
        "&alternatives=true&"
        "access_token=$accessKey");

    var responseString = response.body;
    var data = json.decode(responseString);

    List<dynamic> coords1 = data['routes'][0]['geometry']['coordinates'];
    for (List<dynamic> i in coords1) {
      double o = i[1];
      double p = i[0];
      finalistsafe.add(LatLng(o, p));
    }
  }

  Future<void> getPolygons() async {
    //    getting info xml
    Response info_xml = await get("https://covid.gccservice.in/api/csr/"
        "hotspots?dummy=${DateTime.now().millisecondsSinceEpoch}");
    String goodXmlString = info_xml.body;

//    converting into json
    myTransformer.parse(goodXmlString);
    String json = myTransformer.toBadgerfish();

//    parsing json and iterating
    for (int i = 0;
        i < jsonDecode(json)['kml']['Document']['Placemark'].length;
        i++) {
      List<String> curr_opi = jsonDecode(json)['kml']['Document']['Placemark']
                  [i]['Polygon']['outerBoundaryIs']['LinearRing']['coordinates']
              [r"$"]
          .split(r",0\n              ");

      //      parsing json
      String last = curr_opi.last.replaceAll(r',0\n            ', '');
      String first = curr_opi[0].replaceAll('              ', '');
      curr_opi.removeLast();
      curr_opi.removeAt(0);
      curr_opi.insert(curr_opi.length, last);
      curr_opi.insert(0, first);
      last = '';
      first = '';

//      storing latlong in the format of Point()
      List<Point<num>> dummy = [];
      int order_of_d = 0;
      while (order_of_d <= (curr_opi.length - 1)) {
        dummy.add(Point(num.parse(curr_opi[order_of_d].split(',')[1]),
            num.parse(curr_opi[order_of_d].split(',')[0])));
        order_of_d += 1;
      }
      coords.add([dummy]);
    }
  }

  LatLng nextValidPoint(int index, List<LatLng> container) {
    for (int k = index; k < container.length; k++) {
      for (List<dynamic> i in coords) {
        if (plygn.Polygon(i[0]).isPointInside(
                plygn.Point(container[k].latitude, container[k].longitude)) ==
            false) {
          return container[k];
        }
      }
    }
    return container[container.length - 1];
  }

  Future<void> getSafestRoute(LatLng startingpt, LatLng endingpt) async {
    double start_lat = startingpt.latitude;
    double start_lng = startingpt.longitude;
    double end_lat = endingpt.latitude;
    double end_lng = endingpt.longitude;

    saferoute1.add(startingpt);

    String accessKey =
        'pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg';

    //This gives the json response of the route between 2 points
    Response response = await get(
        "https://api.mapbox.com/directions/v5/mapbox/driving/$start_lng,$start_lat;$end_lng,$end_lat?"
        "geometries=geojson"
        "&alternatives=true&"
        "access_token=$accessKey");

    var responseString = response.body;
    var data = json.decode(responseString);

    List<dynamic> coords1 = data['routes'][0]['geometry']['coordinates'];
    for (List<dynamic> i in coords1) {
      double o = i[1];
      double p = i[0];
      saferoute1.add(LatLng(o, p));
    }

    saferoute1.add(endingpt);

    int index = 0;
    LatLng loopchecker = saferoute1[0];
    while (loopchecker != endingpt) {
      LatLng j = saferoute1[index];
      for (List<dynamic> i in coords) {
        if (plygn.Polygon(i[0])
                .isPointInside(plygn.Point(j.latitude, j.longitude)) ==
            true) {
          LatLng nextValidOne = nextValidPoint(saferoute1.indexOf(j) - 1,
              saferoute1.sublist(index, saferoute1.length));
          apisafe(saferoute1[saferoute1.indexOf(j) - 1], nextValidOne);

          presaferoute = saferoute1.sublist(0, saferoute1.indexOf(j));
          sufsaferoute = saferoute1.sublist(
              saferoute1.indexOf(nextValidOne), saferoute1.length);
          presaferoute.addAll(finalistsafe);
          presaferoute.addAll(subsubsaferoute);
          saferoute1 = presaferoute;
        }
      }
      index = index + 1;
      loopchecker = saferoute1[index];
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
                points: saferoute1,
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
