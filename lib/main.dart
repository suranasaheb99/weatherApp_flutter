import 'dart:convert';
// import 'dart:html';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';

void main() => runApp(WeatherApp());


class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {

  int temperature;
  String location = 'London';
  int woeid = 44418;
  String searchApiUrl = 'https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';
  String weather = 'clear';
  String abbreviation = '';
  String errorMessage = '';

  @override
  void initState() {     // to get rid of initial condition
    super.initState();
    fetchLocation();
  }

  void fetchSearch(String input) async {
    try {
      var searchResult = await http.get(searchApiUrl + input);
      var result = json.decode(searchResult.body)[0];


      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage ='';
      });
    }
    catch(error){
      setState(() {
        errorMessage = "Please search for valid Location";
      });
    }
  }

  void fetchLocation() async{
    var locationResult = await http.get(locationApiUrl + woeid.toString());
    var result = jsonDecode(locationResult.body);
    var consolidated_weather = result["consolidated_weather"];
    var data = consolidated_weather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ','').toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });

  }
  void onTextFieldSubmitted(String input) async {
    await fetchSearch(input);
    await fetchLocation();
  }      //here async solved the problem of searching one place multiple times for data


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blueGrey
      ),
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/$weather.png'),
            fit: BoxFit.cover
          ),
          ),
        child: temperature == null ? Center(child: CircularProgressIndicator()) : SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    Center(
                      child: Image.network('https://www.metaweather.com/static/img/weather/png/'+ abbreviation + '.png',
                      width: 100,
                      ),
                    ),
                    Center(
                      child: Text(
                        temperature.toString() + '\u2103',
                        style: TextStyle(
                          fontSize: 60.0,
                          color: Colors.white54
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        location.toString(),
                        style: TextStyle(
                          fontSize: 40.0,
                          color: Colors.white,
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      width: 300,
                      child: TextField(
                        onSubmitted: (String input){
                          onTextFieldSubmitted(input);
                        },
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 25,
                          ),
                        decoration: InputDecoration(
                            hintText: 'Search Another Location',
                          hintStyle: TextStyle(
                            fontSize: 20,
                          ),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: Platform.isAndroid? 15.0:20.0
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        ),
      );
  }
}



