import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'api_key.dart'; // Replace this with your Google Maps API key file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(), // Your main screen
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace with your main screen layout
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => mapPage(title: 'Map Page')),
            );
          },
          child: Text('Go to Map Page'),
        ),
      ),
    );
  }
}


// Center of the Google Map
const initialPosition = LatLng(37.7786, -122.4375);
// Hue used by the Google Map Markers to match the theme
const _pinkHue = 350.0;
// Places API client used for Place Photos
final _placesApiClient = GoogleMapsPlaces(apiKey: googleMapsApiKey);

class mapPage extends StatefulWidget {

  final String title;

  const mapPage({required this.title, Key? key}) : super(key: key);

  @override
  _mapPageState createState() => _mapPageState();
}

class _mapPageState extends State<mapPage> {
  late Stream<QuerySnapshot> _iceCreamStores;
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _iceCreamStores = FirebaseFirestore.instance
        .collection('ice_cream_stores')
        .orderBy('name')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _iceCreamStores,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Loading...'));
          }
          return Stack(
            children: [
              StoreMap(
                documents: snapshot.data!.docs,
                initialPosition: initialPosition,
                mapController: _mapController,
              ),
              StoreCarousel(
                mapController: _mapController,
                documents: snapshot.data!.docs,
              ),
            ],
          );
        },
      ),
    );
  }
}

class StoreCarousel extends StatelessWidget {
  const StoreCarousel({
    super.key,
    required this.documents,
    required this.mapController,
  });

  final List<DocumentSnapshot> documents;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          height: 90,
          child: StoreCarouselList(
            documents: documents,
            mapController: mapController,
          ),
        ),
      ),
    );
  }
}

class StoreCarouselList extends StatelessWidget {
  const StoreCarouselList({
    super.key,
    required this.documents,
    required this.mapController,
  });

  final List<DocumentSnapshot> documents;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return SizedBox(
          width: 340,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Card(
              child: Center(
                child: StoreListTile(
                  document: documents[index],
                  mapController: mapController,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StoreListTile extends StatefulWidget {
  const StoreListTile({
    super.key,
    required this.document,
    required this.mapController,
  });

  final DocumentSnapshot document;
  final Completer<GoogleMapController> mapController;

  @override
  State<StatefulWidget> createState() {
    return _StoreListTileState();
  }
}

class _StoreListTileState extends State<StoreListTile> {
  String _placePhotoUrl = '';
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _retrievePlacesDetails();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _retrievePlacesDetails() async {
    final details = await _placesApiClient
        .getDetailsByPlaceId(widget.document['placeId'] as String);
    if (!_disposed) {
      setState(() {
        _placePhotoUrl = _placesApiClient.buildPhotoUrl(
          photoReference: details.result.photos[0].photoReference,
          maxHeight: 300,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.document['name'] as String),
      subtitle: Text(widget.document['address'] as String),
      leading: SizedBox(
        width: 100,
        height: 100,
        child: _placePhotoUrl.isNotEmpty
            ? ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          child: Image.network(_placePhotoUrl, fit: BoxFit.cover),
        )
            : Container(),
      ),
      onTap: () async {
        final controller = await widget.mapController.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                widget.document['location'].latitude as double,
                widget.document['location'].longitude as double,
              ),
              zoom: 16,
            ),
          ),
        );
      },
    );
  }
}

class StoreMap extends StatelessWidget {
  const StoreMap({
    super.key,
    required this.documents,
    required this.initialPosition,
    required this.mapController,
  });

  final List<DocumentSnapshot> documents;
  final LatLng initialPosition;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 12,
      ),
      markers: documents
          .map((document) => Marker(
        markerId: MarkerId(document['placeId'] as String),
        icon: BitmapDescriptor.defaultMarkerWithHue(_pinkHue),
        position: LatLng(
          document['location'].latitude as double,
          document['location'].longitude as double,
        ),
        infoWindow: InfoWindow(
          title: document['name'] as String?,
          snippet: document['address'] as String?,
        ),
      ))
          .toSet(),
      onMapCreated: (mapController) {
        this.mapController.complete(mapController);
      },
    );
  }
}