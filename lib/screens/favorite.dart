// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:auto_size_text/auto_size_text.dart';
import 'package:browser_agevole/main.dart';
import 'package:browser_agevole/utils.dart/web_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final favoritesCollection = firestore.collection('favorites');
    final webLinksCollection = firestore.collection('webLinks');
    final personalFavoritesCollection =
        firestore.collection('personalFavorites');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AdminHomePage(),
          );
        },
        backgroundColor: darkColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: FutureBuilder<DocumentSnapshot>(
          future: favoritesCollection.doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data?.data() == null) {
              return Center(
                  child: Text(
                'No favorites added yet',
                style: TextStyle(
                  color: darkColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ));
            }

            List<String> favoriteLinkIds =
                List<String>.from(snapshot.data?['links'] ?? []);

            return StreamBuilder(
              stream: webLinksCollection
                  .where(FieldPath.documentId, whereIn: favoriteLinkIds)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> linkSnapshot) {
                if (linkSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (linkSnapshot.hasError ||
                    !linkSnapshot.hasData ||
                    linkSnapshot.data!.docs.isEmpty) {
                  return Center(child: const Text(''));
                }

                final links = linkSnapshot.data?.docs ?? [];

                return StreamBuilder<DocumentSnapshot>(
                  stream: personalFavoritesCollection.doc(userId).snapshots(),
                  builder: (context, personalSnapshot) {
                    if (personalSnapshot.hasError) {
                      return Center(
                          child:
                              const Text('Error loading personal favorites.'));
                    }

                    List<Map<String, dynamic>> personalLinks = [];
                    if (personalSnapshot.hasData &&
                        personalSnapshot.data?.data() != null) {
                      personalLinks = List<Map<String, dynamic>>.from(
                          personalSnapshot.data?['links'] ?? []);
                    }

                    final combinedLinks = [...links, ...personalLinks];

                    return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisExtent: 100,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: combinedLinks.length,
                        itemBuilder: (context, index) {
                          final link = combinedLinks[index];

                          // Check if link is a QueryDocumentSnapshot (from 'links')
                          if (link is QueryDocumentSnapshot) {
                            final linkData =
                                link.data() as Map<String, dynamic>;
                            final url = linkData['url'] as String;
                            final name = linkData['name'] as String;
                            final icon = linkData['icon'] as String?;

                            // If no icon is provided, use the default favicon.ico path
                            final faviconUrl =
                                icon ?? '${Uri.parse(url).origin}/favicon.ico';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        WebViewPage(url: url),
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
                              child: Column(
                                children: [
                                  // Display the favicon image (using the 'faviconUrl')
                                  Image.network(
                                    faviconUrl,
                                    height: 60,
                                    width: 60,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.error,
                                        size: 65,
                                        color: Colors.grey.withAlpha(
                                            180), // Customize the error icon color
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 5),
                                  Text(name),
                                ],
                              ),
                            );
                          }
                          // Handle personal favorites directly as Map<String, dynamic>
                          else if (link is Map<String, dynamic>) {
                            final url = link['url'] as String;
                            final faviconUrl =
                                '${Uri.parse(url).origin}/favicon.ico';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        WebViewPage(url: url),
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
                              child: Column(
                                children: [
                                  Image.network(
                                    faviconUrl,
                                    height: 60,
                                    width: 60,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.language_rounded,
                                        size: 60,
                                        color: Colors.grey.withAlpha(
                                            180), // Customize the error icon color
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
                          }
                          // Placeholder widget for unexpected cases
                          else {
                            return const SizedBox.shrink();
                          }
                        });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({
    super.key,
  });

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _addPersonalFavorite(String name, String url) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final personalFavoritesCollection =
        firestore.collection('personalFavorites');
    final userDoc = personalFavoritesCollection.doc(userId);

    // Add the new link to the user's personal favorites
    await userDoc.set({
      'links': FieldValue.arrayUnion([
        {
          'name': name,
          'url': url,
        }
      ])
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: mainColor,
            border: Border(
              top: BorderSide(color: darkColor, width: 3),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 20),
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: darkColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Title',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 7),
                      TextFormField(
                        autofocus: true,
                        controller: nameController,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Google, Facebook, etc..',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: darkColor,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: darkColor,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(7),
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(7),
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a name' : null,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Redirection Link',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 7),
                      TextFormField(
                        controller: linkController,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'https://',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.paste, color: darkColor),
                            onPressed: () async {
                              ClipboardData? data =
                                  await Clipboard.getData('text/plain');
                              if (data != null) {
                                linkController.text = data.text ?? '';
                              }
                            },
                            tooltip: 'Paste',
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(7),
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(7),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: darkColor,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: darkColor,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a name' : null,
                      ),
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            final name = nameController.text.trim();
                            final url = linkController.text.trim();

                            if (name.isNotEmpty && url.isNotEmpty) {
                              _addPersonalFavorite(name, url).then((_) {
                                setState(
                                    () {}); // Refresh the page to show the new favorite
                                Navigator.of(context).pop();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkColor,
                            alignment: Alignment.center,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Text(
                              'Add Website'.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
