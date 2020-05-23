import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart';
import 'package:mapsuiprojectprac/ui/search/next_page.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:xml2json/xml2json.dart';

class LoadingScreen extends StatefulWidget {
  final String from;
  final String to;
  final bool enable;
  final bool repeat;
  LoadingScreen(this.from, this.to, this.enable, this.repeat);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final myTransformer = Xml2Json();
  List<Marker> allMarkers = [];
  List<String> places = [];
  List<LatLng> route1 = [];
  List<List> coordinates = [];
  List<Polyline> polyline = [];
  double slat, slng;
  Location location = new Location();
  LocationData locationData;
  bool enable;
  bool repeat = false;
  String http;

  @override
  void initState() {
    places.add(widget.from);
    places.add(widget.to);
    enable = widget.enable;
    repeat = widget.repeat;
    super.initState();
    // USE UR FN INSTEAD OF THIS getLocationData fn.
    fetchroute();
    //getLocationData();
  }

  fetchroute() async {
    try {
      final query = places[0];
      if (places[0] == 'Your Location' ||
          places[0] == 'நீங்கள் இருக்கும் இடம்') {
        final locationData = await location.getLocation();
        slat = locationData.latitude;
        slng = locationData.longitude;
      } else {
        var addresses = await Geocoder.local.findAddressesFromQuery(query);
        var first = addresses.first;
        slat = first.coordinates.latitude;
        slng = first.coordinates.longitude;
      }
      final query1 = places[1];
      var addresses1 = await Geocoder.local.findAddressesFromQuery(query1);
      var first1 = addresses1.first;
      allMarkers.add(
        new Marker(
          width: 45.0,
          height: 45.0,
          point: new LatLng(slat, slng),
          builder: (context) => new Container(
            child: IconButton(
              color: Colors.deepPurple,
              icon: Icon(Icons.location_on),
              iconSize: 45.0,
              onPressed: () {},
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
      getSafestRouteUsingApi(
        LatLng(slat, slng),
        LatLng(first1.coordinates.latitude, first1.coordinates.longitude),
      );
      setState(() {});
    } catch (e) {
      ajyncConfirmDialog0(context);
      Navigator.pop(context);
    }
  } //geocodes the input source and destination,gets the route if error,shows a dialog box

  Future<void> ajyncConfirmDialog0(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: enable ? Text('Uh ho!') : Text('Uh ho!'),
          content: enable
              ? Text('No Places Found')
              : Text('இடங்கள் எதுவும் கிடைக்கவில்லை'),
          actions: <Widget>[
            FlatButton(
              child: enable ? Text('OK') : Text('சரி'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> ajyncConfirmDialog1(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: enable
              ? Text(
                  'ALERT!!',
                  style: (TextStyle(color: Colors.red)),
                )
              : Text(
                  'எச்சரிக்கை',
                  style: (TextStyle(color: Colors.red)),
                ),
          content: enable
              ? Text('The Source Location is in Containment Zone')
              : Text(
                  'இருப்பிடம் கட்டுப்பாட்டு மண்டலத்தில்(Containment Zone) உள்ளது'),
          actions: <Widget>[
            FlatButton(
              child: enable ? Text('OK') : Text('சரி'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> ajyncConfirmDialog2(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: enable
              ? Text(
                  'ALERT!!',
                  style: (TextStyle(color: Colors.red)),
                )
              : Text(
                  'எச்சரிக்கை',
                  style: (TextStyle(color: Colors.red)),
                ),
          content: enable
              ? Text('The destination is in the containment zone')
              : Text(
                  'சேரும் இடம் கட்டுப்பாட்டு மண்டலத்தில்(Containment Zone) உள்ளது'),
          actions: <Widget>[
            FlatButton(
              child: enable ? Text('OK') : Text('சரி'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> ajyncConfirmDialog3(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: enable
              ? Text(
                  'ALERT!!',
                  style: (TextStyle(color: Colors.red)),
                )
              : Text(
                  'எச்சரிக்கை',
                  style: (TextStyle(color: Colors.red)),
                ),
          content: enable
              ? Text('There is no safest route possible')
              : Text('பாதுகாப்பான பாதை எதுவும் இல்லை'),
          actions: <Widget>[
            FlatButton(
              child: enable ? Text('OK') : Text('சரி'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getSafestRouteUsingApi(LatLng start, LatLng end) async {
    double lat1 = start.latitude;
    double lng1 = start.longitude;
    double lat2 = end.latitude;
    double lng2 = end.longitude;
    String lang = enable ? 'en-gb' : 'ta';

    Response response = await get(
        "https://ceg-maps.herokuapp.com/getRoute?st_lat=$lat1&st_lng=$lng1&e_lat=$lat2&e_lng=$lng2&lang=$lang");
    print(response.body);
    var data = json.decode(response.body);

    http = data['http'];

    if (data['warning'] == 1) {
      ajyncConfirmDialog1(context);
      Navigator.pop(context);
      return;
    } else if (data['warning'] == 2) {
      ajyncConfirmDialog2(context);
      Navigator.pop(context);
      return;
    } else if (data['warning'] == 3) {
      ajyncConfirmDialog3(context);
      Navigator.pop(context);
      return;
    } else if (data['warning'] == 4) {
      ajyncConfirmDialog2(context);
      Navigator.pop(context);
      return;
    }

    List<dynamic> coordinates1 = data['route'];
    for (String i in coordinates1) {
      var a = i.split(",");
      double o = double.parse(a[0]);
      double p = double.parse(a[1]);
      route1.add(LatLng(o, p));
    }

    int duration = data['duration'];
    int distance = data['distance'];

    setState(() {});
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => NextPage(
                places[0],
                places[1],
                route1,
                allMarkers,
                LatLng(lat1, lng1),
                LatLng(lat2, lng2),
                enable,
                http,
                duration,
                distance)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitSpinningCircle(
              color: Colors.white,
              size: 100.0,
            ),
            SizedBox(
              height: 15.0,
            ),
            enable
                ? Text(
                    'Fetching the Safest Route...',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  )
                : Text('பாதுகாப்பான வழியைப் பெறுகிறது...',
                    style: TextStyle(fontSize: 12, color: Colors.white)),
            SizedBox(
              height: 15.0,
            ),
            repeat
                ? Text(
                    'You have deviated from the route...Re-routing again...',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  )
                : Text(
                    ' ',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
            repeat
                ? Text(
                    'நீங்கள் பாதையிலிருந்து விலகிவிட்டீர்கள் ...',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  )
                : Text(
                    ' ',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
            repeat
                ? Text(
                    'புதிய பாதுகாப்பான வழியைப் பெறுகிறது...',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  )
                : Text(
                    ' ',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  )
          ],
        ),
      ),
    );
  }
}
