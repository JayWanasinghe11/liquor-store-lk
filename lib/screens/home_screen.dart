import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/glass_app_bar.dart';
import '../services/firestore_service.dart';
import '../models/cart_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";
  String selectedCategory = "All";

  final List<String> imgList = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  final List<String> categories = ["All", "Whisky", "Beer", "Gin", "Wine", "Vodka"];

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 220,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 800,
                    ),
                    autoPlayCurve: Curves.fastOutSlowIn,
                  ),
                  items: imgList
                      .map(
                        (item) => Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                item,
                              ), 
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),

                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Premium Collections",
                        style: GoogleFonts.oswald(
                          color: Colors.amber,
                          fontSize: 24,
                        ),
                      ),
                      const Text(
                        "Get your favorite drinks delivered to your doorstep.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: 40,
                  right: 15,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/admin_login');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 10,
                  top: 40,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/admin_login'),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: TextField(
                onChanged: (value) {
                  setState(() => searchQuery = value.toLowerCase());
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search your drink...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.amber),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryChip(category, selectedCategory == category);
                  },
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Mchan, mokakda ada bonne? Ask our AI sommelier!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: const Text(
                      "Ask",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(
                selectedCategory == "All" ? "Popular Drinks" : "$selectedCategory Collections",
                style: GoogleFonts.oswald(color: Colors.white, fontSize: 20),
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getDrinks(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(
                    child: Text("Error!", style: TextStyle(color: Colors.red)),
                  );
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  final category = data.containsKey('category') ? data['category'].toString() : '';

                  bool matchesSearch = name.contains(searchQuery);
                  bool matchesCategory = selectedCategory == "All" || category.toLowerCase() == selectedCategory.toLowerCase();

                  return matchesSearch && matchesCategory;
                }).toList();

                if (docs.isEmpty)
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "Not found mchan!",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  );

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildProductCard(
                      context,
                      docs[index].id,
                      data['name'] ?? 'Unknown',
                      data['price']?.toString() ?? '0.00',
                      data['imageUrl'] ?? '',
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => Navigator.pushNamed(context, '/cart'),
        child: const Icon(Icons.shopping_cart, color: Colors.black),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.amber,
        backgroundColor: Colors.grey[900],
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (bool selected) {
          setState(() {
            selectedCategory = label;
          });
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String id,
    String name,
    String price,
    String imgUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: imgUrl.isNotEmpty
                  ? Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(
                          Icons.wine_bar,
                          color: Colors.amber,
                          size: 50,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.wine_bar,
                        color: Colors.amber,
                        size: 50,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "LKR $price",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(
                        id,
                        name,
                        double.parse(price.replaceAll(',', '')),
                        imgUrl,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.05),
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: Colors.amber, width: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(color: Colors.amber, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}