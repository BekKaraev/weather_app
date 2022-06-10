import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/citi_page.dart';
import 'package:weather_app/constans.dart';

import 'utils/weather_utils.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({
    Key key,
  }) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String _celcius = '';
  String _icons;
  String _description = '';
  String _cityName = '';
  bool _isLoading = false;

  @override
  void initState() {
    _showWeatherByLocation();

    super.initState();
  }

  Future<void> _showWeatherByLocation() async {
    setState(() {
      _isLoading = true;
    });
    final position = await _getCurrentLocation();
    await getWetherByLocation(position: position);
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> getWetherByLocation({@required Position position}) async {
    final client = http.Client();
    try {
      setState(() {
        _isLoading = true;
      });
      Uri uri = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey');
      final response = await client.get(uri);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        final _data = jsonDecode(body) as Map<String, dynamic>;

        final kelvin = _data['main']['temp'] as num;
        log('main===>$_data');
        _cityName = _data['name'];
        _celcius = WeatherUtils.kelvinToCelcius(kelvin).toString();
        _description = WeatherUtils.getDescription(int.parse(_celcius));
        _icons = WeatherUtils.getWeatherIcon(kelvin.toInt());
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      throw Exception(e);
    }
  }

  Future<void> _getWeatherByCityName(String typedCityName) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final client = http.Client();

      final url =
          'https://api.openweathermap.org/data/2.5/weather?q=$typedCityName&appid=$apiKey';
      Uri uri = Uri.parse(url);
      final response = await client.get(uri);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        log('body ===> $body');
        final _data = jsonDecode(body) as Map<String, dynamic>;
        // final kelvin = _data['main']['temp'] as num;
        _cityName = _data['name'];

        //  _celcius = WeatherUtils.kelvinToCelcius(kelvin) as String;
        //  _icons = WeatherUtils.getWeatherIcon(kelvin);
        _description = WeatherUtils.getDescription(int.parse(_celcius));
        setState(() {
          _isLoading = false;
        });
      }
    } catch (katany) {
      setState(() {
        _isLoading = false;
      });
      throw Exception(katany);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: const Icon(
          Icons.navigation,
          size: 60.0,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: IconButton(
              onPressed: () async {
                setState(() {});
                final _typedCity = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => CityPage()),
                  ),
                );

                log('typedCity -===> $_typedCity');
                _getWeatherByCityName(_typedCity).toString();
              },
              icon: const Icon(
                Icons.location_city,
                size: 60.0,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(
                backgroundColor: Colors.blue,
                color: Colors.teal,
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/weather.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _celcius.isEmpty
                          ? '$_celcius \u00B0 🌦'
                          : '$_celcius  \u00B0 $_icons',
                      style: const TextStyle(
                        fontSize: 100.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _cityName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 50.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Text(
                      _description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 60.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
