import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LugopPrimaryApp());
}

class LugopPrimaryApp extends StatelessWidget {
  const LugopPrimaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LUGOP Primary RMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PrimaryWebViewScreen(),
    );
  }
}

class PrimaryWebViewScreen extends StatefulWidget {
  const PrimaryWebViewScreen({Key? key}) : super(key: key);

  @override
  State<PrimaryWebViewScreen> createState() => _PrimaryWebViewScreenState();
}

class _PrimaryWebViewScreenState extends State<PrimaryWebViewScreen> {
  late final WebViewController controller;

  // 1. YOUR PRIMARY SCHOOL ENTRY PORTAL LINK
  final String entryPortalUrl = 'https://script.google.com/macros/s/AKfycbwY9kkOKIs9sv6O3CC1mwza6XSnWUdslT7sV3tYZlsNJ-BQjQmB8hnLhrE3cvcrUZ0w_Q/exec?school=naluso%20l.e.a';

  // 2. YOUR SOCIAL / CONTACT LINKS
  // For WhatsApp, use international format without '+' (e.g., 265888123456)
  final Uri whatsappUrl = Uri.parse('https://wa.me/265882192585');
  final Uri facebookUrl = Uri.parse('https://www.facebook.com/john.liwinya');
  final Uri suggestionsUrl = Uri.parse('https://www.facebook.com/YOUR_FACEBOOK_PAGE'); // Or a feedback link

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) setState(() => isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(entryPortalUrl));
  }

  // Function to open external links safely
  Future<void> _launchExternalUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await controller.canGoBack()) {
          await controller.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF003366),
          elevation: 0,
          title: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/logo.png',
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.school, color: Color(0xFF003366)),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LUGOP Primary RMS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Mark Entry Portal',
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Colors.white),
              onSelected: (String value) {
                if (value == 'whatsapp') {
                  _launchExternalUrl(whatsappUrl);
                } else if (value == 'facebook') {
                  _launchExternalUrl(facebookUrl);
                } else if (value == 'suggestions') {
                  _launchExternalUrl(suggestionsUrl);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'whatsapp',
                  child: Row(
                    children: [
                      Icon(Icons.chat, color: Colors.green),
                      SizedBox(width: 8),
                      Text('WhatsApp Support'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'facebook',
                  child: Row(
                    children: [
                      Icon(Icons.facebook, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Facebook Page'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'suggestions',
                  child: Row(
                    children: [
                      Icon(Icons.feedback, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Suggestions & Feedback'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003366)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}