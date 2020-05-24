import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapsuiprojectprac/ui/search/splashscreen.dart';
import 'ui/search/from_to.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';

void main() {
  return runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => SplashScreen(),
      '/second': (context) => FirstRoute(),
      // When navigating to the "/second" route, build the SecondScreen widget.
    },
  ));
}

class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Scaffold(
          backgroundColor: Colors.white70,
          appBar: AppBar(
            title: Text('Make My Secure Route'),
            backgroundColor: Colors.deepPurple,
          ),
          body: Mapdemo(),
        ),
      ),
    );
  }
}

class Mapdemo extends StatefulWidget {
  @override
  _MapdemoState createState() => _MapdemoState();
}

class _MapdemoState extends State<Mapdemo> {
  MapController controller = new MapController();

  double a = 13.08;
  double b = 80.27;
  List<Marker> markers = [];
  bool enable = true;
  List<Polyline> coords = [];

  @override
  void initState() {
    super.initState();
  }

  void getLocation() async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    a = position.latitude;
    b = position.longitude;
    controller.move(new LatLng(a, b), 10.0);
    markers.clear();
    markers.add(new Marker(
      width: 40.0,
      height: 40.0,
      point: new LatLng(a, b),
      builder: (context) => new Container(
        child: IconButton(
          icon: Icon(Icons.my_location),
          color: Colors.blueAccent,
          iconSize: 45.0,
          onPressed: () {
            print('Marker tapped');
          },
        ),
      ),
    ));
    //setState(() {
    //a = position.latitude;
    //b = position.longitude;
    //});
  }

  void placeMarkerAdd(String placename) async {
    final query = placename;
    var addresses = await Geocoder.local.findAddressesFromQuery(query);
    var first = addresses.first;
    controller.move(
        new LatLng(first.coordinates.latitude, first.coordinates.longitude),
        15.0);
    markers.add(
      new Marker(
        width: 45.0,
        height: 45.0,
        point:
            new LatLng(first.coordinates.latitude, first.coordinates.longitude),
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
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          new FlutterMap(
              options: new MapOptions(center: new LatLng(a, b), minZoom: 15.0),
              mapController: controller,
              layers: [
                new TileLayerOptions(
                    urlTemplate:
                        "https://api.mapbox.com/styles/v1/ammaamma/ck98c24q356631ip7xkk1vkq0/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg",
                    additionalOptions: {
                      'accessToken':
                          'pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg',
                      'id': 'mapbox.terrain-rgb'
                    }),
                new MarkerLayerOptions(markers: markers),
                new PolylineLayerOptions(polylines: coords),
              ]),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.my_location, color: Colors.white),
                      tooltip: 'Your Location',
                      onPressed: () {
                        getLocation();
                      },
                    ),
                    decoration: const ShapeDecoration(
                      color: Colors.deepPurple,
                      shape: CircleBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    decoration: const ShapeDecoration(
                      color: Colors.deepPurple,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      tooltip: 'Search',
                      onPressed: () {
                        //showSearch(context: context, delegate: DataSearch());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapBoxAutoCompleteWidget(
                              apiKey:
                                  'pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg',
                              hint: "Select starting point",
                              country: 'in',
                              language: enable ? 'en' : 'ta',
                              onSelect: (place) {
                                //_startPointController.text = place.placeName;
                                placeMarkerAdd(place.placeName);
                                Navigator.pop(context);
                              },
                              limit: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    decoration: const ShapeDecoration(
                      color: Colors.deepPurple,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.directions, color: Colors.white),
                      tooltip: 'Get Safe Route',
                      onPressed: () {
                        var route = new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                SearchPaage(enable, '', ''));
                        Navigator.of(context).push(route);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: RaisedButton(
                  onPressed: () {
                    setState(() {
                      enable = !enable;
                    });
                  },
                  child: enable
                      ? const Text('தமிழில் மொழிபெயர்க்கவும்',
                          style: TextStyle(fontSize: 14))
                      : const Text('Switch to English',
                          style: TextStyle(fontSize: 20)),
                  color: Colors.deepPurple,
                  textColor: Colors.white,
                  elevation: 5,
                )),
          ),
        ],
      ),
    );
  }
}
