import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class ReaderScreen extends StatefulWidget {
  final int bookId;

  const ReaderScreen({super.key, required this.bookId});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int _currentPage = 1;
  static const int _totalPages = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 3.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl:
                      'https://picsum.photos/seed/page${_currentPage}_book${widget.bookId}/800/1100',
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Text(
                      'Failed to load page',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Page controls
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 32),
                  onPressed: _currentPage > 1
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                Text(
                  'Page $_currentPage of $_totalPages',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right,
                      color: Colors.white, size: 32),
                  onPressed: _currentPage < _totalPages
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
          ),
          // Security note
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: AppColors.primaryRed,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  'Secure Reader • Screenshots blocked',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
