import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'city_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyWeatherApp(),
    );
  }
}

class MyWeatherApp extends StatefulWidget {
  @override
  _MyWeatherAppState createState() => _MyWeatherAppState();
}

class _MyWeatherAppState extends State<MyWeatherApp> {
  var temp = '';
  var city = '';
  var condition = '_unknown';
  var cityOrGPS = '';
  var latitude = 0.0;
  var longitude = 0.0;
  bool showBottomSheet = false;
  bool needToShowBottomSheet = false;

  MapboxMapController mapController;

  void getData() async {
    Response response = await get(
        'https://api.openweathermap.org/data/2.5/weather?$cityOrGPS&appid=key&units=metric&lang=ru');

    if (response.statusCode == 200) {
      print(response.body);
      String data = response.body;

      setState(() {
        temp = jsonDecode(data)['main']['temp'].toString();
        condition = jsonDecode(data)['weather'][0]['icon'];
        city = jsonDecode(data)['name'];
        latitude = jsonDecode(data)['coord']['lat'];
        longitude = jsonDecode(data)['coord']['lon'];

        needToShowBottomSheet = true;

        mapController.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 12.0,
            ),
          ),
        );
      });
    } else {
      print(response.statusCode);
    }
  }

  getCurrentLocation() async {
    await Geolocator.getCurrentPosition().then((Position position) {
      setState(() {
        cityOrGPS = 'lat=${position.latitude}&lon=${position.longitude}';
        getData();
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Погода в городе $city'),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation),
            tooltip: 'По GPS',
            onPressed: () {
              getCurrentLocation();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MapboxMap(
            accessToken: 'token',
            initialCameraPosition: CameraPosition(
              zoom: 12.0,
              target: LatLng(61.0393, 30.1291),
            ),
            rotateGesturesEnabled: false,
            trackCameraPosition: true,
            onMapCreated: (MapboxMapController controller) {
              mapController = controller;
              mapController.addListener(onMapChanged);
            },
            onMapClick: (Point<double> point, LatLng position) async {
              mapController.clearCircles();
              await mapController.addCircle(
                CircleOptions(
                  circleRadius: 8.0,
                  circleColor: '#006992',
                  circleOpacity: 0.8,
                  geometry: position,
                  draggable: false,
                ),
              );

              cityOrGPS = 'lat=${position.latitude}&lon=${position.longitude}';
              getData();
            },
          ),
          Container(
            padding: EdgeInsets.only(top: 10.0, left: 10.0),
            child: FloatingActionButton.extended(
                onPressed: () async {
                  city = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CityList();
                      },
                    ),
                  );
                  cityOrGPS = 'q=$city';
                  getData();
                },
                label: Text('Выбрать город')),
          ),
        ],
      ),
      bottomSheet: showBottomSheet
          ? BottomSheet(
              enableDrag: false,
              elevation: 10,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              onClosing: () {
// Do something
              },
              builder: (BuildContext ctx) => Container(
                    width: double.infinity,
                    height: 250,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Температура воздуха: $temp °C',
                          style: TextStyle(fontSize: 17.0),
                        ),
                        Image(
                          image: AssetImage('images/cond$condition.png'),
                        ),
                      ],
                    ),
                  ))
          : null,
    );
  }

  void onMapChanged() {
    if (!mapController.isCameraMoving && needToShowBottomSheet) {
      setState(() {
        showBottomSheet = true;
        needToShowBottomSheet = false;
      });
    }

    num abs(num val) => val < 0 ? -val : val;

    if (mapController.isCameraMoving && showBottomSheet) {
      var currentCameraPosition = mapController.cameraPosition;
      if (abs(currentCameraPosition.target.longitude - longitude) > 0.01 ||
          abs(currentCameraPosition.target.latitude - latitude) > 0.01) {
        setState(() {
          showBottomSheet = false;
        });
      }
    }
  }
}
