import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math';
import 'package:poly/poly.dart' as plygn;
import 'spinkit.dart';

// ignore: camel_case_types
class mapi extends StatefulWidget {
  final List<LatLng> route;
  final LatLng dest;
  final bool enable;
  final LatLng source;
  final String http;
  final int duration;
  final int distance;
  final String to;
  mapi(this.route, this.dest, this.enable, this.source, this.http,
      this.duration, this.distance, this.to);
  @override
  _mapiState createState() => _mapiState();
}

class _mapiState extends State<mapi> {
  Location location = new Location();
  List<LatLng> route = [];
  List<LatLng> route1 = [];
  bool enable;
  LatLng dest;
  LatLng source;
  String http;
  String to;

  double rot;
  List<plygn.Point> polygon_points;
  double currentlat;
  double currentlng;

  MapController mapController = MapController();

  List<dynamic> instructions = [];
  List<dynamic> ko;

  String current_instruction;
  double current_arrow;
  int current_len;
  int current_time;
  int u;

  int totaltime = 6000;
  int totallength = 100000;
  int minustime = 0;
  int minuslength = 0;

  Map all_action_arrows = {
    'continue': -1.0,
    'depart': -0.96,
    'rightUTurn': -0.93,
    'leftUTurn': -0.89,
    'rightFork': -0.85,
    'leftFork': -0.81,
    'rightMerge': -0.85,
    'leftMerge': -0.81,
    'slightRightTurn': -0.78,
    'slightLeftTurn': -0.74,
    'rightTurn': -0.71,
    'leftTurn': -0.67,
    'sharpRightTurn': -0.64,
    'sharpLeftTurn': -0.60,
    'rightRoundaboutExit1': -0.20,
    'rightRoundaboutExit2': -0.16,
    'rightRoundaboutExit3': -0.12,
    'rightRoundaboutExit4': -0.09,
    'rightRoundaboutPass': -0.09,
    'rightRoundaboutExit5': -0.06,
    'rightRoundaboutExit6': -0.02,
    'rightRoundaboutExit7': 0.02,
    'rightRoundaboutExit8': 0.05,
    'rightRoundaboutExit9': 0.09,
    'rightRoundaboutExit10': 0.12,
    'rightRoundaboutExit11': 0.15,
    'rightRoundaboutExit12': 0.165,
    'leftRoundaboutExit1': 0.23,
    'leftRoundaboutExit2': 0.27,
    'leftRoundaboutExit3': 0.31,
    'leftRoundaboutExit4': 0.34,
    'leftRoundaboutPass': 0.34,
    'leftRoundaboutExit5': 0.38,
    'leftRoundaboutExit6': 0.42,
    'leftRoundaboutExit7': 0.46,
    'leftRoundaboutExit8': 0.49,
    'leftRoundaboutExit9': 0.525,
    'leftRoundaboutExit10': 0.56,
    'leftRoundaboutExit11': 0.60,
    'leftRoundaboutExit12': 0.63,
    'arrive': 0.674,
    'leftRamp': -0.49,
    'rightRamp': -0.455,
    'leftExit': -0.415,
    'rightExit': -0.385
  };

  Response response;
  bool repeat = true;
  List<Polygon> polygon = [];

  List<List<double>> awq = [];

  int time;
  String strtime;
  final Distance distance = new Distance();
  Map k;

  void moooooove(double a, double b) {
    mapController.move(LatLng(a, b), 18);
  }

  List<List<double>> dedupBy<T, I>(List<T> list, I Function(T) compare,
      {removeLast: true}) {
    int shift = removeLast ? 1 : 0;
    List temp = list.sublist(0, list.length - 1);

    I compareItem;
    for (int i = temp.length - 1; i >= 0; i--) {
      if (compareItem == (compareItem = compare(temp[i]))) {
        temp.removeAt(i + shift);
      }
    }
    return temp;
  }

  List<List<plygn.Point>> equation_finder(List<double> p1, List<double> p2) {
    double m = (p2[1] - p1[1]) / (p2[0] - p1[0]);
    double c = p1[1] - (m * p1[0]);

    double d = 0.00009;

    double f = sqrt((pow(d, 2)) / (1 + (1 / pow(m, 2))));
    double x_p1_p = p1[0] + f;
    double x_p1_m = p1[0] - f;
    double y_p1_p = (-1 / m) * (x_p1_p) + ((p1[1] + (p1[0] / m)));
    double y_p1_m = (-1 / m) * (x_p1_m) + ((p1[1] + (p1[0] / m)));

    double x_p2_p = p2[0] + f;
    double x_p2_m = p2[0] - f;
    double y_p2_p = (-1 / m) * (x_p2_p) + ((p2[1] + (p2[0] / m)));
    double y_p2_m = (-1 / m) * (x_p2_m) + ((p2[1] + (p2[0] / m)));

    return [
      [plygn.Point(x_p1_m, y_p1_m), plygn.Point(x_p2_m, y_p2_m)],
      [plygn.Point(x_p1_p, y_p1_p), plygn.Point(x_p2_p, y_p2_p)]
    ];
  }

  List<plygn.Point> polygon_creater(List<List<double>> list_o) {
    List<plygn.Point> list_with_m = [];
    List<plygn.Point> list_with_p = [];
    List temp_r =
        dedupBy(list_o, (innerList) => innerList[0], removeLast: false);

    int order = 0;
    while (order < temp_r.length - 1) {
      List temp_i = equation_finder(temp_r[order], temp_r[order + 1]);
      list_with_m.add(temp_i[0][0]);
      list_with_m.add(temp_i[0][1]);
      list_with_p.add(temp_i[1][0]);
      list_with_p.add(temp_i[1][1]);
      order++;
    }

    List<plygn.Point> result = [];

    result.addAll(list_with_m);
    result.addAll(list_with_p.reversed);
    result.add(list_with_m[0]);
    return result;
  }

  Future<void> getting_info() async {
    try {
      response = await get(http);

      ko = jsonDecode(response.body)['response']['route'][0]['leg'][0]
          ['maneuver'];

      for (dynamic x in ko) {
        String c = x['action'];
        dynamic v = x['travelTime'];
        dynamic a = x['length'];

        instructions.add([
          c,
          v,
          a,
          LatLng(x['position']['latitude'], x['position']['longitude']),
          x['instruction'],
          all_action_arrows[c]
        ]);
      }
      u = instructions.length - 1;

      for (Map x in jsonDecode(response.body)['response']['route'][0]['leg'][0]
          ['link']) {
        List l1 = x['shape'][0].split(',');
        List l2 = x['shape'][1].split(',');
        awq.add([double.parse(l1[0]), double.parse(l1[1])]);
        awq.add([double.parse(l2[0]), double.parse(l2[1])]);
      }

      polygon_points = polygon_creater(awq);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    route1.addAll(widget.route);
    dest = widget.dest;
    enable = widget.enable;
    source = widget.source;
    to = widget.to;
    http = widget.http;
    totaltime = widget.duration;
    totallength = widget.distance;

    rot = 0;

    super.initState();

    location.getLocation().then((v) {
      currentlat = v.latitude;
      currentlng = v.longitude;
      setState(() {});
    });

    getting_info().then((value) {
      setState(() {
        if (u >= 0) {
          current_arrow = instructions[(instructions.length - 1) - u][5];
          current_instruction = instructions[(instructions.length - 1) - u][4];
          current_len = instructions[(instructions.length - 1) - u][2];
          current_time = instructions[(instructions.length - 1) - u][1];
          if ((totaltime) ~/ 3600 != 0) {
            strtime = enable
                ? '${(totaltime) ~/ 3600} hr ${(totaltime) % 3600 ~/ 60} min'
                : '${(totaltime) ~/ 3600} மணி ${(totaltime) % 3600 ~/ 60} நிமி';
          } else {
            strtime =
                enable ? '${totaltime ~/ 60} min' : '${totaltime ~/ 60} நிமி';
          }
        }
        u -= 1;
      });
      instructions.removeAt(0);
    });

    List<bool> offroute_tracker = [];
    location.onLocationChanged.listen((LocationData currentLocation) {
      //1.instructins
      if (distance.as(
              LengthUnit.Meter,
              LatLng(currentLocation.latitude, currentLocation.longitude),
              instructions[0][3]) <=
          65) {
        setState(() {
          if (u >= 0) {
            current_arrow = instructions[(instructions.length - 1) - u][5];
            current_instruction =
                instructions[(instructions.length - 1) - u][4];
            current_len = instructions[(instructions.length - 1) - u][2];
            current_time = instructions[(instructions.length - 1) - u][1];
            minustime += instructions[(instructions.length) - u][1];
            minuslength += instructions[(instructions.length) - u][2];
            time = (totaltime - minustime) ~/ 60;
            if ((totaltime - minustime) ~/ 3600 != 0) {
              strtime = enable
                  ? '${(totaltime - minustime) ~/ 3600} hr ${(totaltime - minustime) % 3600 ~/ 60} min'
                  : '${(totaltime - minustime) ~/ 3600} மணி ${(totaltime - minustime) % 3600 ~/ 60} நிமி';
            } else {
              strtime = enable ? '${time} min' : '${time} நிமி';
            }
          }
          u -= 1;
        });
        instructions.removeAt(0);
      }

      //2.offruting
      if (plygn.Polygon(polygon_points).isPointInside(plygn.Point(
              currentLocation.latitude, currentLocation.longitude)) ==
          false) {
        if (distance.as(
                LengthUnit.Meter,
                LatLng(currentLocation.latitude, currentLocation.longitude),
                source) <=
            60) {
          offroute_tracker.add(true);
        } else {
          offroute_tracker.add(false);
        }
      }

      if (offroute_tracker.length > 15) {
        offroute_tracker.removeAt(0);
      }

      try {
        if (offroute_tracker[0] == false &&
            offroute_tracker[1] == false &&
            offroute_tracker[2] == false &&
            offroute_tracker[3] == false &&
            offroute_tracker[4] == false) {
          var route = new MaterialPageRoute(
              builder: (BuildContext context) =>
                  LoadingScreen('Your Location', to, enable, repeat));
          Navigator.of(context).pushReplacement(route);
        }
      } catch (e) {}

      setState(() {
        currentlat = currentLocation.latitude;
        currentlng = currentLocation.longitude;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        body: SafeArea(
          child: new Stack(
            children: <Widget>[
              new FlutterMap(
                  mapController: mapController,
                  options: new MapOptions(
                    onTap: (location) {
                      print('gg');
                    },
                    center: LatLng(currentlat, currentlng),
                    minZoom: 7.0,
                    maxZoom: 18.0,
                    rotation: rot,
                  ),
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
                        strokeWidth: 15.0,
                        color: Colors.blue.withOpacity(0.8),
                      ),
                    ]),
                    new MarkerLayerOptions(markers: [
                      new Marker(
                        height: 49.0,
                        width: 63.0,
                        point: new LatLng(currentlat, currentlng),
                        builder: (context) => new Container(
                          child: IconButton(
                              icon: Icon(Icons.radio_button_checked),
                              iconSize: 45.0,
                              onPressed: () {},
                              color: Colors.deepPurple),
                        ),
                      ),
                    ]),
                  ]),
              GestureDetector(
                onTap: () {},
                child: Column(
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: new BoxConstraints(
                        minHeight: 120,
                        minWidth: MediaQuery.of(context).size.width,
                        maxHeight: 120,
                        maxWidth: MediaQuery.of(context).size.width,
                      ),
                      child: new DecoratedBox(
                        decoration: new BoxDecoration(color: Colors.deepPurple),
                        child: Row(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                ConstrainedBox(
                                  constraints: new BoxConstraints(
                                    minHeight: 100,
                                    minWidth: 100,
                                    maxHeight: 100,
                                    maxWidth: 100,
                                  ),
                                  child: Image.asset(
                                    "assets/arrows1.png",
                                    fit: BoxFit.cover,
                                    height: 10.0,
                                    width: 10.0,
                                    scale: 3.0,
                                    alignment:
                                        new Alignment(current_arrow, -1.0),
                                  ),
                                ),
                                enable
                                    ? Text(
                                        '$current_len m',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        '$current_len மீ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: ConstrainedBox(
                                constraints: new BoxConstraints(
                                  minHeight: 100,
                                  minWidth:
                                      (MediaQuery.of(context).size.width - 100),
                                  maxHeight: 100,
                                  maxWidth:
                                      (MediaQuery.of(context).size.width - 100),
                                ),
                                child: enable
                                    ? Text(
                                        '${current_instruction.split('.')[0]}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        '${current_instruction.split('.')[0]}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  child: ConstrainedBox(
                    constraints: new BoxConstraints(
                      minHeight: 100,
                      minWidth: MediaQuery.of(context).size.width,
                      maxHeight: 100,
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child: new DecoratedBox(
                      decoration: new BoxDecoration(color: Colors.deepPurple),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 24, 110, 0),
                            child: Column(
                              children: <Widget>[
                                ConstrainedBox(
                                  constraints: new BoxConstraints(
                                    minHeight: 30,
                                    minWidth:
                                        (MediaQuery.of(context).size.width -
                                            200),
                                    maxHeight: 30,
                                    maxWidth:
                                        (MediaQuery.of(context).size.width -
                                            200),
                                  ),
                                  child: enable
                                      ? Text(
                                          '${strtime}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          '${strtime}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                                ConstrainedBox(
                                  constraints: new BoxConstraints(
                                    minHeight: 45,
                                    minWidth:
                                        (MediaQuery.of(context).size.width -
                                            200),
                                    maxHeight: 45,
                                    maxWidth:
                                        (MediaQuery.of(context).size.width -
                                            200),
                                  ),
                                  child: enable
                                      ? Text(
                                          '${double.parse(((totallength - minuslength) / 1000).toStringAsFixed(1))} km',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          '${double.parse(((totallength - minuslength) / 1000).toStringAsFixed(1))} கி.மீ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: SizedBox.fromSize(
                                size: enable
                                    ? Size(56, 56)
                                    : Size(48, 48), // button width and height
                                child: ClipOval(
                                  child: Material(
                                    color:
                                        Colors.deepPurpleAccent, // button color
                                    child: InkWell(
                                      splashColor: Colors.green, // splash color
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      }, // button pressed
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.close,
                                              color: Colors.white), // icon
                                          enable
                                              ? Text("End",
                                                  style: TextStyle(
                                                      color: Colors.white))
                                              : Text(
                                                  "நிறுத்து",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8,
                                                  ),
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
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.0),
                child: Align(
                  alignment: Alignment(-1.0, 0.6),
                  child: SizedBox.fromSize(
                    size: Size(76, 76), // button width and height
                    child: ClipOval(
                      child: Material(
                        color: Colors.deepPurple, // button color
                        child: InkWell(
                          splashColor: Colors.green, // splash color
                          onTap: () {
                            mapController.move(
                                LatLng(currentlat, currentlng), 18);
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
    } catch (e) {
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
                      style: TextStyle(fontSize: 12, color: Colors.white))
            ],
          ),
        ),
      );
    }
  }
}
