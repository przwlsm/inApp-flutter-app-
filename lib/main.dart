import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the status bar color to #14646F
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF14646F),
    statusBarIconBrightness: Brightness.light, // White icons for battery/network
    statusBarBrightness: Brightness.dark,      // For iOS status bar icons
  ));

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14646F)),
        useMaterial3: true,
      ),
      home: const WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  
  // Your Netlify URL
  final String url = "https://bankdepositapp.netlify.app/";

  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true,
      useHybridComposition: true,
      allowsBackForwardNavigationGestures: true
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14646F),
      body: SafeArea(
        child: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: WebUri(url)),
          initialSettings: settings,
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onPermissionRequest: (controller, request) async {
            // Ask for camera/mic permission ONLY when the website requests it
            for (var resource in request.resources) {
              if (resource == PermissionResourceType.CAMERA) {
                await Permission.camera.request();
              }
              if (resource == PermissionResourceType.MICROPHONE) {
                await Permission.microphone.request();
              }
            }
            
            return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT);
          },
          onLoadStop: (controller, url) async {
            // Page finished loading
          },
        ),
      ),
    );
  }
}
