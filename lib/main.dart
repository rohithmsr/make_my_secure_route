import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'ui/search/search_page.dart';
import 'package:mapbox_search/mapbox_search.dart';
//import 'ui/search/iterate.dart';
//import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';

///the search alone will have problem...others will work properly
///PLEASE USE YOUR OWN MAPBOX API KEY

void main() {
  return runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => FirstRoute(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/second': (context) => SearchPaage(),
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
            title: Text('Make My Safest Route'),
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

  void getLocation() async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    a = position.latitude;
    b = position.longitude;
    controller.move(new LatLng(a, b), 15.0);
    setState(() {
      a = position.latitude;
      b = position.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _startPointController = TextEditingController();

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
                new MarkerLayerOptions(markers: [
                  new Marker(
                    width: 40.0,
                    height: 40.0,
                    point: new LatLng(a, b),
                    builder: (context) => new Container(
                      child: IconButton(
                        icon: Icon(Icons.location_on),
                        color: Colors.red,
                        iconSize: 45.0,
                        onPressed: () {
                          print('Marker tapped');
                        },
                      ),
                    ),
                  )
                ])
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
                        showSearch(context: context, delegate: DataSearch());
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
                        Navigator.pushNamed(context, '/second');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final cities = [
    "Andhra Pradesh",
    "Arunachal Pradesh ",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jammu and Kashmir",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli",
    "Daman and Diu",
    "Lakshadweep",
    "National Capital Territory of Delhi",
    "Puducherry"
  ];

  final recentCities = [
    "Tamil Nadu",
    "Kerala",
  ];

  List<MapBoxPlace> liist = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    // actions for appbar
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon n appbar's left
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    placesSearch(String query) async {
      String apiKey =
          'pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg'; //Set up a test api key before running

      var placesService = PlacesSearch(
        apiKey: apiKey,
        country: "IN",
        limit: 15,
      );

      var places = await placesService.getPlaces(query);

      for (int i = 0; i < places.length; i++) {
        liist.add(places[i]);
      }
    }

    placesSearch('Anna');
    List suggestionList = query.isEmpty ? recentCities : liist;

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.location_on),
        title: Text(suggestionList[index]),
      ),
      itemCount: suggestionList.length,
    );
  }
}
