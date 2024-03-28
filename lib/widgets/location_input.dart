import 'dart:math';

import 'package:favorites_places/model/place.dart';
import 'package:favorites_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectPlace});

  final void Function(PlaceLocation location) onSelectPlace;

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _locationData;
  var _isLoading = false;
  String get locationImage {
    if (_locationData == null) {
      return '';
    }
    final lat = _locationData!.latitude;
    final lng = _locationData!.longitude;
    String apiKey = 'AIzaSyBBAcQd1bALvibQhKU6N3Rg015_kZpUktE';
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=$apiKey';
  }

  void _getCurrentLocation() async {
    try {
      Location location = Location();

      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      setState(() {
        _isLoading = true;
      });
      locationData = await location.getLocation();
      // var apiKey = 'AIzaSyBBAcQd1bALvibQhKU6N3Rg015_kZpUktE';
      // var url = Uri.parse(
      //     'https://maps.googleapis.com/maps/api/geocode/json?latlng=${locationData.latitude},${locationData.longitude}&key=$apiKey');

      // final response = await http.get(url);
      // final responseData = json.decode(response.body);
      var cities = [
        'New York',
        'Los Angeles',
        'Chicago',
        'Houston',
        'Phoenix',
        'Philadelphia',
        'San Antonio',
        'San Diego',
        'Dallas',
        'San Jose'
      ];
      var rng = Random();
      var randomCity = cities[rng.nextInt(cities.length)];
      final address = randomCity; // api key has expired

      setState(() {
        _locationData = PlaceLocation(
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
          address: address,
        );
        _isLoading = false;
      });

      widget.onSelectPlace(_locationData!);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectOnmap() {
    Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => const MapScreen(
          isSelecting: true,
        ),
      ),
    ).then((selectedLocation) {
      if (selectedLocation == null) {
        return;
      }
      setState(() {
        _locationData = PlaceLocation(
          latitude: selectedLocation.latitude,
          longitude: selectedLocation.longitude,
          address: 'Dummy Address',
        );
      });
      widget.onSelectPlace(_locationData!);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No Location Chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );

    if (_locationData != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    if (_isLoading) {
      previewContent = const CircularProgressIndicator();
    }
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
              onPressed: _getCurrentLocation,
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
              onPressed: _selectOnmap,
            ),
          ],
        ),
      ],
    );
  }
}
