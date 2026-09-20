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
  late final WebViewController controller;
  final String targetUrl = "http://127.0.0.1:8080";

  bool isMinimized = false;
  bool isMaximized = false;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = "";

  double currentWidth = 360;
  double currentHeight = 520;

  double posX = 0;
  double posY = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = false;
              hasError = true;
              errorMessage = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(targetUrl));
  }

  void _updateOverlaySize(double width, double height) {
    setState(() {
      currentWidth = width;
      currentHeight = height;
    });
    FlutterOverlayWindow.resizeOverlay(width.toInt(), height.toInt(), true);
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
        child: Stack(
          children: [
            Column(
              children: [
                GestureDetector(
                  onPanUpdate: (details) {
                    posX += details.delta.dx;
                    posY += details.delta.dy;
                    FlutterOverlayWindow.moveOverlay(
                      OverlayPosition(posX, posY),
                    );
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    color: const Color(0xFF2D2D2D),
                    child: Row(
                      children: [
                        const Icon(Icons.language, size: 18, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Localhost Viewer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18, color: Colors.white70),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            controller.reload();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isMinimized ? Icons.aspect_ratio : Icons.remove,
                            size: 18,
                            color: Colors.white70,
                          ),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              isMinimized = !isMinimized;
                              isMaximized = false;
                            });
                            if (isMinimized) {
                              _updateOverlaySize(180, 48);
                            } else {
                              _updateOverlaySize(360, 520);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isMaximized ? Icons.close_fullscreen : Icons.open_in_full,
                            size: 16,
                            color: Colors.white70,
                          ),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              isMaximized = !isMaximized;
                              isMinimized = false;
                            });
if (isMaximized) {
                              _updateOverlaySize(380, 680);
                            } else {
                              _updateOverlaySize(360, 520);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          onPressed: () => FlutterOverlayWindow.closeOverlay(),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isMinimized)
                  Expanded(
                    child: Stack(
                      children: [
                        WebViewWidget(controller: controller),
                        if (isLoading)
                          const Center(
                            child: CircularProgressIndicator(color: Colors.blueAccent),
                          ),
                        if (hasError)
                          Container(
                            color: const Color(0xFF1E1E1E),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.wifi_off, size: 40, color: Colors.orangeAccent),
                                const SizedBox(height: 8),
                                const Text(
                                  "Gagal Terhubung ke Localhost",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Pastikan server 'run-beres' aktif di port 8080.\n($errorMessage)",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                                  onPressed: () => controller.reload(),
                                  icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                                  label: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            if (!isMinimized && !isMaximized)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    double newWidth = (currentWidth + details.delta.dx).clamp(200.0, 500.0);
                    double newHeight = (currentHeight + details.delta.dy).clamp(150.0, 900.0);
                    _updateOverlaySize(newWidth, newHeight);
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    color: Colors.transparent,
                    child: const Icon(
                      Icons.south_east,
                      size: 14,
                      color: Colors.white38,
                    ),
                  ),
                ),
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
      enableDrag: false,
      height: 520,
      width: 360,
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
