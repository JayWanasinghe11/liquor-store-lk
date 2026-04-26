import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  void _updateStatus(String docId, String currentStatus) {
    String nextStatus = currentStatus == 'Pending' ? 'Delivered' : 'Pending';

    FirebaseFirestore.instance.collection('orders').doc(docId).update({
      'status': nextStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          "ADMIN - ALL ORDERS",
          style: TextStyle(color: Colors.amber),
        ),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('orderDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final docId = orders[index].id;
              final status = order['status'] ?? 'Pending';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer: ${order['customerName']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Phone: ${order['phone']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Address: ${order['address']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Divider(color: Colors.white10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Status: $status",
                          style: TextStyle(
                            color: status == 'Pending'
                                ? Colors.amber
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () => _updateStatus(docId, status),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: status == 'Pending'
                                ? Colors.green
                                : Colors.grey[800],
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: Text(
                            status == 'Pending'
                                ? "Mark Delivered"
                                : "Reset to Pending",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
