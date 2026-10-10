import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/reel_item.dart';
import '../services/servers.dart';

class PlayerScreen extends StatefulWidget {
  final ReelItem item;
  const PlayerScreen({super.key, required this.item});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late WebViewController _controller;
  String _currentServer = 'vixsrc';
  int _season = 1;
  int _episode = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _loading = false),
      ));
    _loadStream();
  }

  void _loadStream() {
    setState(() => _loading = true);
    final url = StreamServers.urlFor(
      _currentServer,
      widget.item.mediaType,
      widget.item.id,
      season: _season,
      episode: _episode,
    );
    _controller.loadRequest(Uri.parse(url));
  }

  void _switchServer(String key) {
    setState(() {
      _currentServer = key;
    });
    _loadStream();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF07070A),
        title: Text(item.title, style: const TextStyle(fontSize: 16)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.dns),
            onSelected: _switchServer,
            itemBuilder: (context) => StreamServers.order.map((k) {
              return PopupMenuItem(
                value: k,
                child: Text(StreamServers.servers[k]!['label'] as String),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFFECE8E0))),
              ],
            ),
          ),
          if (item.mediaType == 'tv')
            Container(
              color: const Color(0xFF121216),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _season > 1 ? () => setState(() { _season--; _loadStream(); }) : null,
                  ),
                  Text('S$_season', style: const TextStyle(color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() { _season++; _loadStream(); }),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _episode > 1 ? () => setState(() { _episode--; _loadStream(); }) : null,
                  ),
                  Text('E$_episode', style: const TextStyle(color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() { _episode++; _loadStream(); }),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
