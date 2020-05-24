import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'from_to.dart';
import 'package:geocoder/geocoder.dart';

class markonmap extends StatefulWidget {
  final bool enable;
  final String from;
  final String to;
  markonmap(this.enable, this.from, this.to);
  @override
  _markonmapState createState() => _markonmapState();
}

class _markonmapState extends State<markonmap> {
  MapController controller = new MapController();
  List<Marker> allMarker = [];
  Map marker_latlng = {};
  bool enable;
  List<double> curr_location;
  double a;
  double b;
  String addr = '';
  String toaddr = '';
  String from = '';
  String to = '';

  void getLocation() async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      a = position.latitude;
      b = position.longitude;
    });
    controller.move(LatLng(a, b), 15.0);
  }

  Future<String> getting_address(LatLng from) async {
    final from_coordinates = new Coordinates(from.latitude, from.longitude);
    List<Address> from_addresses =
        await Geocoder.local.findAddressesFromCoordinates(from_coordinates);
    Address from_first = from_addresses.first;

    print("${from_first.addressLine}");
    setState(() {
      addr += "${from_first.addressLine}";
      return addr;
    });
  }

  @override
  void initState() {
    a = 13.08;
    b = 80.110;
    super.initState();
    enable = widget.enable;
    from = widget.from;
    to = widget.to;
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text('Make My Secure Route'),
            backgroundColor: Colors.deepPurple,
          ),
          body: FlutterMap(
              options: new MapOptions(
                  center: new LatLng(a, b),
                  onTap: (location) {
                    setState(() {
                      a = location.latitude;
                      b = location.longitude;
                    });
                  }),
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
                MarkerLayerOptions(
                  markers: [
                    new Marker(
                      width: 45.0,
                      height: 45.0,
                      point: new LatLng(a, b),
                      builder: (context) => new Container(
                        child: IconButton(
                          color: Colors.deepPurple,
                          icon: Icon(Icons.location_on),
                          iconSize: 45.0,
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
        ),
        Positioned(
          bottom: 17.0,
          right: 15.0,
          left: 15.0,
          child: RaisedButton(
            onPressed: () async {
              await getting_address(LatLng(a, b));
              print(addr);
              if (to == 'to') {
                to = addr;
              } else if (from == 'from') {
                from = addr;
              }
              var route = new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      SearchPaage(enable, from, to));
              Navigator.of(context).push(route);
            },
            color: Colors.deepPurple,
            child: enable
                ? const Text('Select',
                    style: TextStyle(fontSize: 20, color: Colors.white))
                : const Text('தேர்ந்தெடு',
                    style: TextStyle(fontSize: 13, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
