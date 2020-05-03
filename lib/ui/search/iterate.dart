/// This file is just for printing the list of places with the keyword 'Anna'
/// Please try to use this function to get the list and use it in search delegate
/// I'm getting the error
/// (type MapBoxPlace is not a subtype of type String)
/// Someone try to rsctify it guyssssssssss.......

import 'package:mapbox_search/mapbox_search.dart';

Future<void> main() async {
  String query = "Anna";
  await placesSearch(query).catchError(print);
}

/* ///Reverse GeoCoding sample call
//Future geoCoding(String apiKey) async {
//  var geoCodingService = ReverseGeoCoding(
//    apiKey: apiKey,
//    country: "IN",
//    limit: 5,
//  );
//
//  var addresses = await geoCodingService.getAddress(Location(
//    lat: -19.984846,
//    lng: -43.946852,
//  ));
//
//  print(addresses);
//} */

///Places search sample call
Future<void> placesSearch(String query) async {
  String apiKey =
      'pk.eyJ1IjoiYW1tYWFtbWEiLCJhIjoiY2s5OGNxdmN2MDE5aDNlbjJkY2JhZmV6NyJ9.WY2_d6FZBxTHbibBaW9vAg'; //Set up a test api key before running

  var placesService = PlacesSearch(
    apiKey: apiKey,
    country: "IN",
    limit: 15,
  );

  List places = await placesService.getPlaces(query);
  print(places);
}
