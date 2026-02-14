// import 'package:flutter/material.dart';
// import '../models/product.dart';
// import '../services/api_service.dart';
// import 'checkout_screen.dart';

// class CartScreen extends StatefulWidget {
//   final String? token; // Pass null if guest
//   final List<Product> initialCart;

//   const CartScreen({super.key, this.token, required this.initialCart});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   late List<Product> cart;

//   @override
//   void initState() {
//     super.initState();
//     cart = List.from(widget.initialCart);
//   }

//   void updateQuantity(Product product, int delta) {
//     setState(() {
//       int index = cart.indexWhere((p) => p.id == product.id);
//       if (index != -1) {
//         cart[index].stock += delta; // Using stock as quantity placeholder
//         if (cart[index].stock < 1) cart.removeAt(index);
//       }
//     });
//   }

//   void removeItem(Product product) {
//     setState(() {
//       cart.removeWhere((p) => p.id == product.id);
//     });
//   }

//   double getTotal() {
//     double total = 0;
//     for (var p in cart) {
//       total += p.price * p.stock;
//     }
//     return total;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Cart")),
//       body: cart.isEmpty
//           ? const Center(child: Text("Your cart is empty"))
//           : ListView.builder(
//               itemCount: cart.length,
//               itemBuilder: (context, index) {
//                 final product = cart[index];
//                 return Card(
//                   margin: const EdgeInsets.all(8),
//                   child: ListTile(
//                     leading: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover),
//                     title: Text(product.name),
//                     subtitle: Text("Price: \$${product.price}\nQty: ${product.stock}"),
//                     trailing: SizedBox(
//                       width: 120,
//                       child: Row(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.remove),
//                             onPressed: () => updateQuantity(product, -1),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.add),
//                             onPressed: () => updateQuantity(product, 1),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete),
//                             onPressed: () => removeItem(product),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(16),
//         color: Colors.white,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text("Total: \$${getTotal().toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ElevatedButton(
//               onPressed: cart.isEmpty
//                   ? null
//                   : () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => CheckoutScreen(token: widget.token, cart: cart),
//                         ),
//                       );
//                     },
//               child: const Text("Checkout"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
