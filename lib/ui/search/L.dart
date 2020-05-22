import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:core';

class navigation1 extends StatefulWidget {
  final List<LatLng> route;
  final LatLng dest;
  final bool enable;
  final LatLng source;
  navigation1(this.route, this.dest, this.enable, this.source);
  @override
  _navigation1State createState() => _navigation1State();
}

class _navigation1State extends State<navigation1> {
  MapController controlleru = new MapController();
  Location location = new Location();
  LocationData locationData;
  bool enable;
  LatLng dest;
  LatLng source;
  double pos_lat = 13.0633213;
  double pos_long = 80.2056;
  List<LatLng> route1 = [];

//  Future<void> getSafestRouteUsingApi(LatLng start, LatLng end) async {
//    double lat1 = start.latitude;
//    double lng1 = start.longitude;
//    double lat2 = end.latitude;
//    double lng2 = end.longitude;
//
//    Response response = await get(
//        "https://route.ls.hereapi.com/routing/7.2/calculateroute.json?apiKey=1m-furr_5hkuA_PIN4j3yvZ8mqIfoRpLuVXDvKAI_r4&waypoint0=geo!$lat1,$lng1&waypoint1=geo!$lat2,$lng2&representation=display&mode=fastest;car;traffic:disabled&instructionFormat=text&language=en-gb&routeattributes=sh,no&maneuverattributes=ac");
//    print(response.body);
//    var data = json.decode(response.body);
//
//    List<dynamic> coordinates1 = data['response']['route'][0]['shape'];
//    print(coordinates1);
//    for (String i in coordinates1) {
//      var a = i.split(",");
//      double o = double.parse(a[0]);
//      double p = double.parse(a[1]);
//      route1.add(LatLng(o, p));
//    }
//    setState(() {});
//  }

  @override
  void initState() {
    route1.addAll(widget.route);
    dest = widget.dest;
    enable = widget.enable;
    source = widget.source;
    print(route1);
    super.initState();
    location.changeSettings(accuracy: LocationAccuracy.navigation);
    setState(() {
      location.onLocationChanged.listen((LocationData currentLocation) {
        setState(() {
          print(currentLocation);
          pos_lat = currentLocation.latitude;
          pos_long = currentLocation.longitude;
          controlleru.move(new LatLng(pos_lat, pos_long), 19.0);
        });
      });
    });
//    getSafestRouteUsingApi(
//        LatLng(13.0833213, 80.2046206), LatLng(13.0833213, 80.2056));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: Image.asset(
            "assets/arrows.png",
            fit: BoxFit.cover,
            alignment: new Alignment(-1.0, -1.0),
          ),
          backgroundColor: Colors.deepPurple,
          title: Text('Your Navigator', textAlign: TextAlign.center),
        ),
        body: new Stack(
          children: <Widget>[
            new FlutterMap(
                options: new MapOptions(
                  onTap: (location) {},
                  center: new LatLng(pos_lat, pos_long),
                  minZoom: 7.0,
                  maxZoom: 18.0,
                ),
                mapController: controlleru,
                layers: [
                  new TileLayerOptions(
                      urlTemplate:
                          "https://api.mapbox.com/styles/v1/ammaamma/ckaa45zz942jt1jo290h5qfso/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg",
                      additionalOptions: {
                        'accessToken':
                            'pk.eyJ1IjoicHJhaGFkZWVzaDE4MDkiLCJhIjoiY2s5OGJ0NmtsMDE0bjNmcDR3aHE0eWxpciJ9.vGw9cZtm_MN3xTGMTkH7RA',
                        'id':
                            'mapbox://styles/ammaamma/ckaa45zz942jt1jo290h5qfso'
                      }),
                  new PolylineLayerOptions(polylines: [
                    new Polyline(
                      points: route1,
                      strokeWidth: 12.0,
                      color: Colors.blue,
                    ),
                  ]),
                  new MarkerLayerOptions(markers: [
                    new Marker(
//                      width: 15,
//                      height: 45,
                      point: new LatLng(pos_lat, pos_long),
                      builder: (context) => new Container(
                        child: IconButton(
                            icon: Icon(Icons.radio_button_checked),
                            iconSize: 45.0,
                            onPressed: () {},
                            color: Colors.deepPurple),
                      ),
                    ),
                    new Marker(
                      width: 5.5,
                      height: 5,
                      point: new LatLng(pos_lat, pos_long),
                      builder: (context) => new Container(
                        child: IconButton(
                            icon: Icon(Icons.navigation),
                            iconSize: 19.0,
                            onPressed: () {},
                            color: Colors.blue),
                      ),
                    ),
                    new Marker(
                      width: 45,
                      height: 45,
                      point: dest,
                      builder: (context) => new Container(
                        child: IconButton(
                            icon: Icon(Icons.flag),
                            onPressed: () {},
                            iconSize: 45.0,
                            color: Colors.deepPurple),
                      ),
                    ),
                  ]),
                ]),
            Padding(
              padding: EdgeInsets.all(14.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: SizedBox.fromSize(
                  size: enable
                      ? Size(56, 56)
                      : Size(76, 76), // button width and height
                  child: ClipOval(
                    child: Material(
                      color: Colors.deepPurple, // button color
                      child: InkWell(
                        splashColor: Colors.green, // splash color
                        onTap: () {
                          Navigator.of(context).pop();
                        }, // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.close, color: Colors.white), // icon
                            enable
                                ? Text("End",
                                    style: TextStyle(color: Colors.white))
                                : Text(
                                    "நிறுத்து",
                                    style: TextStyle(color: Colors.white),
                                  ), // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox.fromSize(
                  size: Size(76, 76), // button width and height
                  child: ClipOval(
                    child: Material(
                      color: Colors.deepPurple, // button color
                      child: InkWell(
                        splashColor: Colors.green, // splash color
                        onTap: () {
                          controlleru.move(new LatLng(pos_lat, pos_long), 19.0);
                        }, // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.center_focus_strong,
                                color: Colors.white), // icon
                            enable
                                ? Text(
                                    "Re-Centre",
                                    style: TextStyle(color: Colors.white),
                                  )
                                : Text(
                                    "Re-Centre",
                                    style: TextStyle(color: Colors.white),
                                  ), // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
