import 'package:flutter/material.dart';

class UniformImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final BoxFit fit;

  const UniformImage({
    Key? key,
    required this.imagePath,
    this.width = 72.0, // default width
    this.height = 95.0, // default height
    this.fit = BoxFit.cover, // default BoxFit
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        imagePath,
        fit: fit,
      ),
    );
  }
}

class NearbyPlacesSubpage extends StatefulWidget {
  @override
  State<NearbyPlacesSubpage> createState() => _NearbyPlacesSubpageState();
}

class _NearbyPlacesSubpageState extends State<NearbyPlacesSubpage> {
  final List<Map<String, dynamic>> locations = [
    {
      'image': 'assests/ans.png',
      'name': 'A & S Lamps - Cubao',
      'description': 'PARKING IS AVAILABLE',
      'fee': 'P50'
    },
    {
      'image': 'assests/nook.png',
      'name': 'The Nook - Anonas',
      'description': 'PARKING IS UNAVAILABLE',
      'fee': 'P50'
    },
    {
      'image': 'assests/wisisi.png',
      'name': 'World Citi Medical Center',
      'description': 'PARKING IS AVAILABLE',
      'fee': 'P50'
    },
    {
      'image': 'assests/putsdam.png',
      'name': '24 Potsdam Street',
      'description': 'PARKING IS UNAVAILABLE',
      'fee': 'P30'
    },
    {
      'image': 'assests/27putsdam.png',
      'name': '27 Potsdam Street',
      'description': 'MOTORCYCLE PARKING ONLY',
      'fee': 'P20'
    },
    {
      'image': 'assests/sentjan.png',
      'name': 'St. John Chapel',
      'description': 'PARKING IS UNAVAILABLE',
      'fee': 'P50'
    },
    {
      'image': 'assests/acc.png',
      'name': 'Anonas City Center',
      'description': 'PARKING AVAILABLE',
      'fee': 'P80'
    },

  ];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredLocations = [];

  @override
  void initState() {
    super.initState();
    filteredLocations = locations; // Start with all locations
    _searchController.addListener(_filterLocations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations() {
    List<Map<String, dynamic>> results = [];
    if (_searchController.text.isEmpty) {
      results = locations;
    } else {
      results = locations
          .where((location) =>
          location['name'].toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredLocations = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Places'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset('assests/map.png', fit: BoxFit.cover, height: double.infinity, width: double.infinity),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(30),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: Colors.greenAccent.withOpacity(0.8),
                  child: ListView.builder(
                    itemCount: filteredLocations.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: UniformImage(imagePath: filteredLocations[index]['image']),
                          title: Text(filteredLocations[index]['name']),
                          subtitle: Text(filteredLocations[index]['description']),
                          trailing: Text('PARKING FEE: ${filteredLocations[index]['fee']}'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}