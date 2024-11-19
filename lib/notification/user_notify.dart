import 'package:auto_size_text/auto_size_text.dart';
import 'package:browser_agevole/main.dart';
import 'package:browser_agevole/utils.dart/web_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class UserNotificationsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void _openInDefaultBrowser(String url) async {
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode
              .externalApplication, // Ensures it opens in the default browser
        );
      } else {
        // Show an error if the URL can't be launched
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the URL: $url')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: darkColor,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
          ),
        ),
        surfaceTintColor: darkColor,
        title: Text(
          'Daily Updates',
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data?.docs ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: GestureDetector(
                  onTap: notification['url'] == ''
                      ? () {}
                      : () {
                          _openInDefaultBrowser(notification['url']);
                        },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    margin: EdgeInsets.only(
                        top: index == 0 ? 10 : 0,
                        bottom: index == (notifications.length - 1) ? 70 : 0),
                    height: 75,
                    decoration: BoxDecoration(
                      color: mainColor,
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Icon(
                              Icons.notifications,
                              color: darkColor,
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              SizedBox(
                                width: notification['url'] == ''
                                    ? MediaQuery.of(context).size.width - (100)
                                    : MediaQuery.of(context).size.width - (140),
                                child: AutoSizeText(
                                  notification['message'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Spacer(),
                          notification['url'] == ''
                              ? Container()
                              : Center(
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: mainColor,
                                      border: Border.all(
                                        color: darkColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(200),
                                    ),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      color: darkColor,
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                ),
              );

              // ListTile(
              //   title: Text(notification['title'] ?? 'No Title'),
              //   subtitle: Text(notification['message'] ?? 'No Message'),
              //   leading: const Icon(Icons.notifications),
              // );
            },
          );
        },
      ),
    );
  }
}
