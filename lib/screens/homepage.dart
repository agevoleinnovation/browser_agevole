import 'package:browser_agevole/main.dart';
import 'package:browser_agevole/utils.dart/web_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference webLinksCollection =
      FirebaseFirestore.instance.collection('webLinks');
  final CollectionReference favoritesCollection =
      FirebaseFirestore.instance.collection('favorites');

  // Get the current user's ID
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  Future<bool> isFavorite(String linkId) async {
    final userFavorites = await favoritesCollection.doc(userId).get();
    if (userFavorites.exists) {
      final List<dynamic> links = userFavorites['links'] ?? [];
      return links.contains(linkId);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: StreamBuilder(
          stream: webLinksCollection.orderBy('order').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: darkColor,
              ));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final links = snapshot.data?.docs ?? [];

            return SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation,
                                  secondaryAnimation) =>
                              WebViewPage(
                                  url: 'https://1xsurat.com/daily-updates/'),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      height: 180,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: mainColor,
                        border: Border.all(
                          color: Colors.grey,
                          width: 0.4,
                        ),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/images/image.png')),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisExtent: 120,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: links.length,
                    itemBuilder: (context, index) {
                      final link = links[index];
                      // final bool advisability = true;
                      // if (!advisability) return const SizedBox.shrink();

                      return FutureBuilder<bool>(
                        future: isFavorite(link.id),
                        builder: (context, snapshot) {
                          bool isFav = snapshot.data ?? false;
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

                                    var tween = Tween(begin: begin, end: end)
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
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  children: [
                                    Image.network(
                                      link['icon'],
                                      height: 63,
                                      width: 63,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.error,
                                          size: 65,
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
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await toggleFavorite(link.id);
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.favorite,
                                      size: 18,
                                      color: isFav ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> toggleFavorite(String linkId) async {
    final userFavorites = favoritesCollection.doc(userId);
    final userFavoritesData = await userFavorites.get();

    if (userFavoritesData.exists &&
        userFavoritesData['links'].contains(linkId)) {
      // Remove from favorites
      userFavorites.update({
        'links': FieldValue.arrayRemove([linkId])
      });
    } else {
      // Add to favorites
      userFavorites.set({
        'links': FieldValue.arrayUnion([linkId])
      }, SetOptions(merge: true));
    }
  }
}
