import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:webview_flutter/webview_flutter.dart';

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FloatingBrowserWindow(),
    ),
  );
}

class FloatingBrowserWindow extends StatefulWidget {
  const FloatingBrowserWindow({super.key});

  @override
  State<FloatingBrowserWindow> createState() => _FloatingBrowserWindowState();
}

class _FloatingBrowserWindowState extends State<FloatingBrowserWindow> {
  bool isMinimized = false;
  late final WebViewController controller;
  final String targetUrl = "http://127.0.0.1:8080"; 

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(targetUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            GestureDetector(
              onPanUpdate: (details) {
                FlutterOverlayWindow.moveOverlay(
                  OverlayPosition(details.globalPosition.dx, details.globalPosition.dy),
                );
              },
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xFF2D2D2D),
                child: Row(
                  children: [
                    const Icon(Icons.language, size: 16, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Localhost Viewer",
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 16, color: Colors.white70),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => controller.reload(),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        isMinimized ? Icons.aspect_ratio : Icons.remove,
                        size: 16,
                        color: Colors.white70,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        setState(() {
                          isMinimized = !isMinimized;
                        });
                        if (isMinimized) {
await FlutterOverlayWindow.resizeOverlay(160, 40, true);
                        } else {
                          await FlutterOverlayWindow.resizeOverlay(360, 520, true);
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => FlutterOverlayWindow.closeOverlay(),
                    ),
                  ],
                ),
              ),
            ),
            if (!isMinimized)
              Expanded(
                child: WebViewWidget(controller: controller),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _startOverlay(BuildContext context) async {
    bool isGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!isGranted) {
      final bool? granted = await FlutterOverlayWindow.requestPermission();
      if (granted != true) return;
    }

    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      height: 1000,
      width: 720,
      alignment: OverlayAlignment.center,
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilitySecret,
      positionGravity: PositionGravity.auto,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Localhost Overlay Launcher"),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          onPressed: () => _startOverlay(context),
          icon: const Icon(Icons.open_in_new, color: Colors.white),
          label: const Text("Buka Floating Browser", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
