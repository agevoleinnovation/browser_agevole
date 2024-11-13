import 'package:browser_agevole/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage>
    with SingleTickerProviderStateMixin {
  late InAppWebViewController webViewController;
  late AnimationController _animationController;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // Check if there is a previous page in the WebView
    if (await webViewController.canGoBack()) {
      // Go back in the WebView
      await webViewController.goBack();
      return false; // Don't pop the WebView page yet
    } else {
      // Exit to the app's home page
      return true; // Allow the page to be popped
    }
  }

  void toggleMenu() {
    setState(() {
      isExpanded = !isExpanded;
      isExpanded
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Attach the onWillPop callback
      child: SafeArea(
        child: Scaffold(
          backgroundColor: mainColor,
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
              ),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
          ),
          floatingActionButton: Stack(
            alignment: Alignment.bottomRight,
            children: [
              if (isExpanded) ...[
                Positioned(
                  bottom: 70,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Go back to app's home
                        },
                        backgroundColor: mainColor,
                        heroTag: 'home',
                        tooltip: 'Home',
                        mini: true,
                        child: Icon(
                          Icons.home_filled,
                          color: darkColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: () async {
                          if (await webViewController.canGoBack()) {
                            await webViewController.goBack();
                          }
                        },
                        heroTag: 'back',
                        backgroundColor: mainColor,
                        tooltip: 'Back',
                        mini: true,
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 30,
                          color: darkColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: () async {
                          await webViewController.reload();
                        },
                        backgroundColor: mainColor,
                        heroTag: 'refresh',
                        tooltip: 'Refresh',
                        mini: true,
                        child: Icon(
                          Icons.refresh_rounded,
                          color: darkColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Positioned(
                bottom: 0,
                child: FloatingActionButton(
                  onPressed: toggleMenu,
                  tooltip: 'Expand Menu',
                  backgroundColor: !isExpanded ? mainColor : darkColor,
                  child: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _animationController,
                    color: !isExpanded ? darkColor : mainColor,
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
