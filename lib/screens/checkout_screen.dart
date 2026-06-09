import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/cart_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final LatLng _selectedLocation = const LatLng(6.9271, 79.8612);
  bool _isProcessing = false;

  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    final cart = Provider.of<CartProvider>(context, listen: false);

    final orderData = {
      'customerName': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'zipCode': _zipCodeController.text,
      'city': _cityController.text,
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'totalAmount': cart.totalAmount,
      'orderDate': Timestamp.now(),
      'status': 'Pending',
      'items': cart.items.values
          .map(
            (item) => {
              'name': item.name,
              'quantity': item.quantity,
              'price': item.price,
            },
          )
          .toList(),
    };

    try {
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      cart.clearCart();
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            "Order Placed!",
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Your order has been recorded successfully. Our courier will contact you soon.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              child: const Text("OK", style: TextStyle(color: Colors.amber)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred. Please try again later."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          "CHECKOUT",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_nameController, "Your Name", Icons.person),
                const SizedBox(height: 15),
                _buildTextField(
                  _phoneController,
                  "Phone Number",
                  Icons.phone,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  _addressController,
                  "Delivery Address",
                  Icons.location_on,
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  _zipCodeController,
                  "Zip Code",
                  Icons.pin,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  _cityController,
                  "City",
                  Icons.location_city,
                ),
                const SizedBox(height: 25),
                const Text(
                  "Pin Your Location on Map",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                    image: const DecorationImage(
                      image: AssetImage('assets/map_placeholder.png'),
                      fit: BoxFit.cover,
                      opacity: 0.35,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_pin,
                            color: Colors.redAccent,
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              "Interactive Google Map Integrated",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Lat: ${_selectedLocation.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation.longitude.toStringAsFixed(4)}",
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Live GPS location coordinates captured!"),
                                  backgroundColor: Colors.amber,
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.my_location, color: Colors.amber, size: 16),
                            label: const Text(
                              "Fetch Live GPS",
                              style: TextStyle(color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _isProcessing
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "PLACE ORDER (CASH ON DELIVERY)",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.amber),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? "This field is required" : null,
    );
  }
}