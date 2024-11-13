import 'package:browser_agevole/main.dart';
import 'package:browser_agevole/notification/user_notify.dart';
import 'package:browser_agevole/utils.dart/web_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:browser_agevole/screens/categories.dart';
import 'package:browser_agevole/screens/favorite.dart';
import 'package:browser_agevole/screens/homepage.dart';
import 'package:android_intent_plus/android_intent.dart';

int selectedIndex = 0;
String website = 'https://agevole.in';
String instagram = 'https://agevole.in';
String facebook = 'https://agevole.in';
String twitter = 'https://agevole.in';
String clientNumber = '8866369688';
String supportMail = 'masumpatel@agevole.in';
String packageName = 'com.agevole.browser';
String playStoreUrl =
    'https://play.google.com/store/apps/details?id=$packageName';

class NavBar extends StatefulWidget {
  final int initialIndex;

  const NavBar({super.key, required this.initialIndex});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const CategoryPage(),
    FavoritesPage(),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    setupFCM();
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else {}

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(message.notification?.title ?? "New Notification"),
          content: Text(message.notification?.body ?? "No message body"),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'App Browser'.toUpperCase(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
          Divider(
            color: Colors.grey,
            thickness: 1.6,
          ),
          ListTile(
            leading: const Icon(Icons.home_filled),
            title: const Text(
              'Home',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            onTap: () {
              setState(() {
                selectedIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.grid_view_rounded),
            title: const Text(
              'Category',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            onTap: () {
              setState(() {
                selectedIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text(
              'Favorite',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            onTap: () {
              setState(() {
                selectedIndex = 2;
              });
              Navigator.pop(context);
            },
          ),
          Divider(
            color: Colors.grey,
            thickness: 0.6,
          ),
          ListTile(
            leading: const Icon(Icons.star_border_rounded),
            title: const Text(
              'Rate the App',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            onTap: rateApp,
          ),
          // ListTile(
          //   leading: const Icon(Icons.share_outlined),
          //   title: const Text(
          //     'Share App',
          //     style: TextStyle(
          //       color: Colors.black,
          //       fontSize: 18,
          //     ),
          //   ),
          //   onTap: () {},
          // ),
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: const Text(
              'Contact Us',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            onTap: contactUs,
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: const Text(
              'Send Feedback',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            onTap: feedbackUs,
          ),
          ListTile(
            leading: const Icon(Icons.messenger_outline_sharp),
            title: const Text(
              'Chat with us',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            onTap: chatWithUs,
          ),
          const Divider(),
          ListTile(
            leading: Image.asset(
              'assets/images/website.png',
              height: 24,
              width: 24,
            ),
            title: const Text(
              'Website',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      WebViewPage(url: website),
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
          ),
          ListTile(
            leading: Image.asset(
              'assets/images/instagram.png',
              height: 24,
              width: 24,
            ),
            title: const Text(
              'Instagram',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      WebViewPage(url: instagram),
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
          ),
          ListTile(
            leading: Image.asset(
              'assets/images/facebook.png',
              height: 24,
              width: 24,
            ),
            title: const Text(
              'Facebook',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      WebViewPage(url: facebook),
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
          ),
          ListTile(
            leading: Image.asset(
              'assets/images/twitter.png',
              height: 24,
              width: 24,
            ),
            title: const Text(
              'Twitter',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      WebViewPage(url: twitter),
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        title: Text(
          selectedIndex == 0
              ? 'APP BROWSER'
              : selectedIndex == 1
                  ? 'CATEGORY'
                  : 'FAVORITE',
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          selectedIndex != 2
              ? IconButton(
                  tooltip: 'Favorite',
                  onPressed: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                  },
                  icon: Icon(
                    Icons.star_outline_rounded,
                    size: 30,
                    color: darkColor,
                  ))
              : Container(),
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: darkColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      UserNotificationsScreen(),
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
          ),
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.menu,
                  color: darkColor,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(selectedIndex),
      drawer: _buildDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: darkColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Customize',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
        currentIndex: selectedIndex,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}

void rateApp() {
  String url = playStoreUrl;
  final AndroidIntent intent = AndroidIntent(
    action: 'action_view',
    data: Uri.parse(url).toString(),
  );
  intent.launch().catchError((e) {});
}

void contactUs() {
  String subject = Uri.encodeComponent("App Browser Support");
  String body = Uri.encodeComponent(
      "Hello, I want to know more about the App Browser.\n\n");

  String url = 'mailto:$supportMail?subject=$subject&body=$body';

  final AndroidIntent intent = AndroidIntent(
    action: 'action_view',
    data: Uri.parse(url).toString(),
  );

  intent.launch().catchError((e) {
    print("Error launching email: $e");
  });
}

void feedbackUs() {
  String subject = Uri.encodeComponent("Feedback for App Browser");
  String body = Uri.encodeComponent("Hello, I want to tell that\n\n");

  String url = 'mailto:$supportMail?subject=$subject&body=$body';

  final AndroidIntent intent = AndroidIntent(
    action: 'action_view',
    data: Uri.parse(url).toString(),
  );

  intent.launch().catchError((e) {
    print("Error launching email: $e");
  });
}

void chatWithUs() {
  String message = '''
Hello, I want to talk with you..
''';

  String url =
      'whatsapp://send?phone=91$clientNumber&text=${Uri.encodeComponent(message)}';
  final AndroidIntent intent = AndroidIntent(
    action: 'action_view',
    data: Uri.parse(url).toString(),
  );
  intent.launch().catchError((e) {});
}
