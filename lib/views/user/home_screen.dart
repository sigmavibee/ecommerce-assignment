import 'package:ecommerce_assignment/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().getUserData(context);
      context.read<ProductController>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final productController = context.watch<ProductController>();

    return Scaffold(
      appBar: AppBar(
        //remove the leading icon to avoid back navigation
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'E-Commerce App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              authController.logout(context);
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${authController.currentUser?.name ?? 'Guest'}!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Find your best deals today.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Search Bar with filter options in side of search with horizontal listview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Open filter options
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Horizontal ListView for Categories
          //text all items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'All Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          // Grid of Products
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: productController.products.isEmpty
                  ? const Center(
                      child: Text(
                        'No products available.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      itemCount: productController.products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final product = productController.products[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              // Navigate to product details
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(18)),
                                    child: Image.network(
                                      product.imageUrl, // Placeholder image
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.description,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            product.price.toStringAsFixed(2),
                                            style: const TextStyle(
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.add_shopping_cart_rounded,
                                                color: Colors.blueAccent),
                                            onPressed: () {
                                              // Add to cart
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.amber,
        height: 60,
        shape: const CircularNotchedRectangle(),
        child: StatefulBuilder(
          builder: (context, setState) {
            int selectedIndex = 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.dashboard,
                    color: selectedIndex == 0 ? Colors.blueAccent : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                    // Go to dashboard
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: selectedIndex == 1 ? Colors.blueAccent : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                    // Go to cart
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: selectedIndex == 2 ? Colors.blueAccent : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                    // Go to edit profile
                  },
                ),
                // IconButton(
                //   icon: Icon(
                //     Icons.logout,
                //     color: selectedIndex == 3 ? Colors.blueAccent : Colors.grey,
                //   ),
                //   onPressed: () {
                //     setState(() {
                //       selectedIndex = 3;
                //     });
                //     // Logout
                //   },
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}
