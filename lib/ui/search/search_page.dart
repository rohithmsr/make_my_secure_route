import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'dart:math';
//import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:core';

/// I am really sorry for the unordered code without proper documentations...
/// please suggest me some measures in writing the code effectivey n properly

class SearchPaage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Soup(),
    );
  }
}

class Soup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make your Safe Route'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white70,
      body: Container(
        child: SearchPage(),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _textController1 = TextEditingController();
  final _textController2 = TextEditingController();

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
            child: TextField(
              cursorColor: Colors.black,
              controller: _textController1,
              decoration: InputDecoration(
                icon: Container(
                  margin: EdgeInsets.only(left: 12.0, bottom: 6),
                  width: 10,
                  height: 10,
                  child: IconButton(
                    icon: Icon(Icons.my_location),
                    color: Colors.deepPurple,
                    onPressed: () {},
                  ),
                ),
                hintText: "From",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
              ),
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
            child: TextField(
              cursorColor: Colors.black,
              controller: _textController2,
              textInputAction: TextInputAction.go,
              decoration: InputDecoration(
                icon: Container(
                  margin: EdgeInsets.only(left: 20, top: 5),
                  width: 10,
                  height: 10,
                  child: Icon(
                    Icons.local_taxi,
                    color: Colors.deepPurple,
                  ),
                ),
                hintText: "To",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
              ),
            ),
          ),
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
            child: const Text(
              'Find Your Safest Route',
              style: TextStyle(fontSize: 20, color: Colors.deepPurple),
            ),
          ),
        ),
      ],
    );
  }
}

class NextPage extends StatefulWidget {
  final String from;
  final String to;
  NextPage(this.from, this.to);

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  List<Marker> allMarkers = [];
  List<String> places = [];
  List<LatLng> route1 = [];
  List<LatLng> route2 = [];
  List<Polyline> polycolourlines = [];
  Map<LatLng, int> dangerpoints1 = {};
  Map<LatLng, int> dangerpoints2 = {};

  @override
  void initState() {
    places.add(widget.from);
    places.add(widget.to);
    fetchroute();
    super.initState();
  }

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

  Future<void> getRoute(LatLng startingpt, LatLng endingpt) async {
    double start_lat = startingpt.latitude;
    double start_lng = startingpt.longitude;
    double end_lat = endingpt.latitude;
    double end_lng = endingpt.longitude;
    int route_cnt1 = 0;
    int route_cnt2 = 0;

    route1.add(startingpt);
    route2.add(startingpt);

    String accessKey =
        'pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg';

    //This gives the json response of the route between 2 points
    Response response = await get(
        "https://api.mapbox.com/directions/v5/mapbox/driving/$start_lng,$start_lat;$end_lng,$end_lat?"
        "geometries=geojson"
        "&alternatives=true&"
        "access_token=$accessKey");

    var responseString = response.body;
    var data = json.decode(responseString); //convert json response to a map

    if (data['routes'].length > 1) {
      List<dynamic> coords1 = data['routes'][0]['geometry'][
          'coordinates']; //this is the list which contains the intermediate points of route1
      for (List<dynamic> i in coords1) {
        double o = i[1];
        double p = i[0];
        route1.add(LatLng(o, p));
      }
      List<dynamic> coords2 =
          data['routes'][1]['geometry']['coordinates']; //route2
      for (List<dynamic> i in coords2) {
        double o = i[1];
        double p = i[0];
        route2.add(LatLng(o, p));
      }
    } else if (data['routes'].length == 1) {
      List<dynamic> coords1 = data['routes'][0]['geometry']['coordinates'];
      for (List<dynamic> i in coords1) {
        double o = i[1];
        double p = i[0];
        route1.add(LatLng(o, p));
      }
    }

    route1.add(endingpt);
    route2.add(endingpt);

    /// Guys we have given the json contents as string,try to store
    /// this file in assets and access that file and convert to string...
    /// someone try guysssssssssssssss.......
    Map opi = json.decode(
        '{"Zone" : {"Adyar" : {"latitude" : 13.001177787780762,"longitude" : 80.2564926147461,"priority" : 2,"radiusInMeters" : 1000,"zoneName" : "Adyar"},"Alandur" : {"latitude" : 12.99748706817627,"longitude" : 80.20063781738281,"priority" : 2,"radiusInMeters" : 1000,"zoneName" : "Alandur"},"Ambattur" : {"latitude" : 13.114338874816895,"longitude" : 80.15478515625,"priority" : 3,"radiusInMeters" : 1000,"zoneName" : "Ambattur"},"Anna Nagar" : {"latitude" : 13.084956169128418,"longitude" : 80.21013641357422,"priority" : 1,"radiusInMeters" : 2000,"zoneName" : "Anna Nagar"},"Kodambakkam" : {"latitude" : 13.052102088928223,"longitude" : 80.22552490234375,"priority" : 1,"radiusInMeters" : 2000,"zoneName" : "Kodambakkam"},"Madhavaram" : {"latitude" : 13.148789405822754,"longitude" : 80.23056030273438,"priority" : 3,"radiusInMeters" : 1000,"zoneName" : "Madhavaram"},"Manali, Chennai" : {"latitude" : 13.177928924560547,"longitude" : 80.27007293701172,"priority" : 3,"radiusInMeters" : 1000,"zoneName" : "Manali, Chennai"},"Perungudi" : {"latitude" : 12.965365409851074,"longitude" : 80.24610900878906,"priority" : 2,"radiusInMeters" : 1000,"zoneName" : "Perungudi"},"Royapuram" : {"latitude" : 13.113700866699219,"longitude" : 80.29541015625,"priority" : 1,"radiusInMeters" : 1500,"zoneName" : "Royapuram"},"Sholinganallur" : {"latitude" : 12.90098762512207,"longitude" : 80.2279281616211,"priority" : 3,"radiusInMeters" : 1000,"zoneName" : "Sholinganallur"},"Teynampet" : {"latitude" : 13.040473937988281,"longitude" : 80.25033569335938,"priority" : 1,"radiusInMeters" : 2000,"zoneName" : "Teynampet"},"Tiru Vi Ka Nagar" : {"latitude" : 13.119937896728516,"longitude" : 80.23422241210938,"priority" : 1,"radiusInMeters" : 1000,"zoneName" : "Tiru Vi Ka Nagar"},"Tiruvottiyur" : {"latitude" : 13.164259910583496,"longitude" : 80.30014038085938,"priority" : 2,"radiusInMeters" : 1000,"zoneName" : "Tiruvottiyur"},"Tondiarpet" : {"latitude" : 13.1317998,"longitude" : 80.274725,"priority" : 1,"radiusInMeters" : 1000,"zoneName" : "Tondiarpet"},"Valasaravakkam" : {"latitude" : 13.04027271270752,"longitude" : 80.17229461669922,"priority" : 2,"radiusInMeters" : 1000,"zoneName" : "Valasaravakkam"}}}');
    //converts json-string to map

    for (LatLng j in route1) {
      int priority = 4;
      for (String i in opi['Zone'].keys) {
        //checks whether the point is in the radius of each n every containment zone
        double lat1 = opi['Zone'][i]['latitude'];
        double lat2 = j.latitude;
        double lon1 = opi['Zone'][i]['longitude'];
        double lon2 = j.longitude;
        const R = 6371e3; // metres
        double psi1 = lat1 * (22 / 7) / 180; // φ, λ in radians
        double psi2 = lat2 * (22 / 7) / 180;
        double delpsi = (lat2 - lat1) * (22 / 7) / 180;
        double dellambda = (lon2 - lon1) * (22 / 7) / 180;

        double a = sin(delpsi / 2) * sin(delpsi / 2) +
            cos(psi1) * cos(psi2) * sin(dellambda / 2) * sin(dellambda / 2);
        double c = 2 * atan2(sqrt(a), sqrt(1 - a));
        double d = R * c; // in metres

        if (d <= opi['Zone'][i]['radiusInMeters']) {
          //if condition true,point is in the radius
          route_cnt1++;
          if (priority > opi['Zone'][i]['priority']) {
            priority = opi['Zone'][i]['priority'];
//            dangerpoints1[j] = priority;
          }
        }
        dangerpoints1[j] = priority;
      }
//      dangerpoints1[j] = priority;
    }

    for (LatLng j in route2) {
      int priority = 4;
      for (String i in opi['Zone'].keys) {
        double lat1 = opi['Zone'][i]['latitude'];
        double lat2 = j.latitude;
        double lon1 = opi['Zone'][i]['longitude'];
        double lon2 = j.longitude;
        const R = 6371e3; // metres
        double psi1 = lat1 * (22 / 7) / 180; // φ, λ in radians
        double psi2 = lat2 * (22 / 7) / 180;
        double delpsi = (lat2 - lat1) * (22 / 7) / 180;
        double dellambda = (lon2 - lon1) * (22 / 7) / 180;

        double a = sin(delpsi / 2) * sin(delpsi / 2) +
            cos(psi1) * cos(psi2) * sin(dellambda / 2) * sin(dellambda / 2);
        double c = 2 * atan2(sqrt(a), sqrt(1 - a));
        double d = R * c; // in metres

        if (d <= opi['Zone'][i]['radiusInMeters']) {
          route_cnt2++;
          if (priority > opi['Zone'][i]['priority']) {
            priority = opi['Zone'][i]['priority'];
//            dangerpoints2[j] = priority;
          }
        }
        dangerpoints2[j] = priority;
      }
    }

    double route1_risk_percnt = (route_cnt1 / route1.length) * 100;
    double route2_risk_percnt = (route_cnt2 / route2.length) * 100;

    if (route2.length == 0) {
      route2 = [];
    } else if (route1_risk_percnt < route2_risk_percnt) {
      route2.clear();
    } else if (route1_risk_percnt > route2_risk_percnt) {
      route1.clear();
    } else if (route1_risk_percnt == route2_risk_percnt) {
      route2.clear();
    }

    if (route2.length == 0) {
      for (LatLng j in dangerpoints1.keys) {
        if (dangerpoints1[j] == 3) {
          polycolourlines.add(new Polyline(
            //draws a polyline from point in containment zone to next point
            points: [
              //route1[route1.indexOf(j) - 1],
              j,
              route1[route1.indexOf(j) + 1]
            ],
            strokeWidth: 6.0,
            color: Colors.green,
          ));
        } else if (dangerpoints1[j] == 2) {
          polycolourlines.add(new Polyline(
            points: [
              //route1[route1.indexOf(j) - 1],
              j,
              route1[route1.indexOf(j) + 1]
            ],
            strokeWidth: 6.0,
            color: Colors.orange,
          ));
        } else if (dangerpoints1[j] == 1) {
          polycolourlines.add(new Polyline(points: [
            //route1[route1.indexOf(j) - 1],
            j,
            route1[route1.indexOf(j) + 1]
          ], strokeWidth: 6.0, color: Colors.red));
        }
      }
    } else {
      for (LatLng j in dangerpoints2.keys) {
        if (dangerpoints2[j] == 3) {
          polycolourlines.add(new Polyline(
            points: [
              //route2[route2.indexOf(j) - 1],
              j,
              route2[route2.indexOf(j) + 1]
            ],
            strokeWidth: 6.0,
            color: Colors.green,
          ));
        } else if (dangerpoints2[j] == 2) {
          polycolourlines.add(new Polyline(
            points: [
              //route2[route2.indexOf(j) - 1],
              j,
              route2[route2.indexOf(j) + 1]
            ],
            strokeWidth: 6.0,
            color: Colors.orange,
          ));
        } else if (dangerpoints2[j] == 1) {
          polycolourlines.add(new Polyline(points: [
            //route2[route2.indexOf(j) - 1],
            j,
            route2[route2.indexOf(j) + 1]
          ], strokeWidth: 6.0, color: Colors.red));
        }
      }
    }
    setState(() {});
  }

  fetchroute() async {
    try {
      final query = places[0];
      var addresses = await Geocoder.local.findAddressesFromQuery(query);
      var first = addresses.first;
      final query1 = places[1];
      var addresses1 = await Geocoder.local.findAddressesFromQuery(query1);
      var first1 = addresses1.first;
      getRoute(
        LatLng(first.coordinates.latitude, first.coordinates.longitude),
        LatLng(first1.coordinates.latitude, first1.coordinates.longitude),
      );
    } catch (e) {
      showAlertDialog(context);
    }
  } //geocodes the input source and destination,gets the route if error,shows a dialog box

  setMarkers() {
    return allMarkers;
  } //not necessary for now

  Future addMarker() async {
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: new Text(
              'Add marker',
              style: new TextStyle(fontSize: 17.0),
            ),
            children: <Widget>[
              new SimpleDialogOption(
                child: new Text('Add markers for the 2 locations',
                    style: new TextStyle(color: Colors.blue)),
                onPressed: () {
                  addToList();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  } //not necessary for now

  addToList() async {
    final query = places[0];
    var addresses = await Geocoder.local.findAddressesFromQuery(query);
    var first = addresses.first;
    //print("${first.featureName} : ${first.coordinates}");
    final query1 = places[1];
    var addresses1 = await Geocoder.local.findAddressesFromQuery(query1);
    var first1 = addresses1.first;
    //print("${first1.featureName} : ${first1.coordinates}");
//    getRoute(
//      LatLng(first.coordinates.latitude, first.coordinates.longitude),
//      LatLng(first1.coordinates.latitude, first1.coordinates.longitude),
//    );
    setState(() {
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
    });
  } //not necessary for now

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
            new MarkerLayerOptions(markers: setMarkers()),
            new PolylineLayerOptions(polylines: [
              new Polyline(
                points: route1,
                strokeWidth: 7.0,
                color: Colors.blue,
              ),
            ]),
            new PolylineLayerOptions(polylines: [
              new Polyline(
                  points: route2, strokeWidth: 7.0, color: Colors.blue),
            ]),
            new PolylineLayerOptions(polylines: polycolourlines),
          ]),
    );
  }
}
