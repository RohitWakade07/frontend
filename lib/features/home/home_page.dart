import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../find_ride/create_ride_page.dart';
import 'view_profile_page.dart'; // Ensure consistent naming
import '../offerRide/offer_ride.dart'; // Ensure consistent naming

class HomePage extends StatefulWidget {
  final String email;
  final String phone;

  const HomePage({
    super.key,
    required this.email,
    required this.phone,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _mapController;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(
        pickupController: _pickupController,
        destinationController: _destinationController,
        onMapCreated: (controller) => _mapController = controller,
      ),
      const Placeholder(), // Replace with dynamic BookRidePage
      ProfilePage(email: widget.email, phone: widget.phone, name: 'User Name'),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Ride Sharing App',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.secondaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car, color: Colors.white),
            onPressed: () {
              // Navigate to OfferRidePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OfferRidePage()),
              );
            },
            tooltip: 'Offer a Ride',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentGreen,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OfferRidePage()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Rides'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: AppColors.accentGreen,
      unselectedItemColor: Colors.white54,
      backgroundColor: AppColors.secondaryDark,
      onTap: _onItemTapped,
    );
  }
}

class HomeContent extends StatelessWidget {
  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final Function(GoogleMapController) onMapCreated;

  const HomeContent({
    super.key,
    required this.pickupController,
    required this.destinationController,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(19.0760, 72.8777),
            zoom: 14,
          ),
          onMapCreated: onMapCreated,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        _buildTopSection(context),
        _buildBottomActionSheet(context),
      ],
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Column(
        children: [
          _buildLocationField(
            controller: pickupController,
            hintText: 'Enter pickup location',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 10),
          _buildLocationField(
            controller: destinationController,
            hintText: 'Where to?',
            icon: Icons.flag,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.secondaryDark,
        prefixIcon: Icon(icon, color: Colors.white54),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildBottomActionSheet(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.secondaryDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              const Center(
                child:
                    Icon(Icons.horizontal_rule_rounded, color: Colors.white54),
              ),
              _buildQuickActions(context),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Recent Rides',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              _buildRecentRides(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: Icons.directions_car,
            label: 'Ride',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CreateRidePage(
                        rideType: 'car',
                      )),
            ),
          ),
          _buildActionButton(
            icon: Icons.directions_bike,
            label: 'Bike',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CreateRidePage(
                        rideType: 'bike',
                      )),
            ),
          ),
          _buildActionButton(
            icon: Icons.delivery_dining,
            label: 'Delivery',
            onPressed: () => _showComingSoon(context),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: AppColors.accentGreen),
          onPressed: onPressed,
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildRecentRides() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text('No recent rides found',
          style: TextStyle(color: Colors.white54)),
    );
  }
}
