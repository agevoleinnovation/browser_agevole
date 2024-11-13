import 'package:auto_size_text/auto_size_text.dart';
import 'package:browser_agevole/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:browser_agevole/utils.dart/web_view.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final CollectionReference webLinksCollection =
      FirebaseFirestore.instance.collection('webLinks');

  Map<String, bool> expandedCategories = {};

  final Map<String, IconData> categoryIcons = {
    'Social Networking': Icons.facebook_rounded,
    'Shopping': Icons.shopping_bag_outlined,
    'News': Icons.newspaper_rounded,
    'Sports': Icons.sports,
    'Education': Icons.school_outlined,
    'Email': Icons.mail_outline_rounded,
    'Travel': Icons.travel_explore_rounded,
    'Job Seeker': Icons.person_outline_rounded,
    'Kids': Icons.train_outlined,
    'Hobby': Icons.local_play_rounded,
    'Booking and Literature': Icons.computer,
    'Health': Icons.computer,
    'Software': Icons.computer,
    'Fashion': Icons.computer,
    'Fitness': Icons.computer,
    'Cooking': Icons.computer,
    'Uncategorized': Icons.category,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: webLinksCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final categories = <String, List<QueryDocumentSnapshot>>{};
          snapshot.data?.docs.forEach((doc) {
            final category = doc['category'] ?? 'Uncategorized';
            if (!categories.containsKey(category)) {
              categories[category] = [];
            }
            categories[category]!.add(doc);
          });

          return ListView(
            children: categories.keys.map((category) {
              final categoryLinks = categories[category]!;
              final isExpanded = expandedCategories[category] ?? false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedCategories[category] = !isExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: mainColor,
                        border: Border.all(
                          color: Colors.grey,
                          width: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    categoryIcons[category] ?? Icons.category,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more),
                            ],
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 15),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisExtent: 90,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: categoryLinks.length,
                              itemBuilder: (context, index) {
                                final link = categoryLinks[index];

                                final bool advisability =
                                    link['advisability'] ?? true;
                                if (!advisability) {
                                  return const SizedBox.shrink();
                                }

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            WebViewPage(url: link['url']),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;

                                          var tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));
                                          var offsetAnimation =
                                              animation.drive(tween);

                                          return SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Image.network(
                                        link['icon'],
                                        height: 50,
                                        width: 50,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.error,
                                            size: 50,
                                            color: darkColor.withAlpha(180),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 5),
                                      AutoSizeText(
                                        link['name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}