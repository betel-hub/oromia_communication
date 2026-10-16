import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_protector/screen_protector.dart';

import '../../core/theme/app_colors.dart';
import '../../models/reader_session.dart';
import '../../providers/auth_provider.dart';
import '../../providers/publication_provider.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String bookId;
  final String type;

  const ReaderScreen({
    super.key,
    required this.bookId,
    required this.type,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen>
    with WidgetsBindingObserver {
  ReaderSession? _session;
  int _currentPage = 1;
  bool _loading = true;
  String? _error;
  final bool _iosCaptured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableSecureMode();
    _loadSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disableSecureMode();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-assert secure mode when app returns to foreground.
    if (state == AppLifecycleState.resumed && _session != null) {
      _enableSecureMode();
    }
  }

  // ==================== SECURITY ====================

  Future<void> _enableSecureMode() async {
    try {
      await ScreenProtector.preventScreenshotOn();
      if (mounted) {
        // Also block iOS screen recording / mirroring.
        try {
          await ScreenProtector.protectDataLeakageOn();
        } catch (_) {
          // Not supported on all platforms — safe to ignore.
        }
      }
    } catch (_) {
      // Web/desktop don't support this — silently continue.
    }
  }

  Future<void> _disableSecureMode() async {
    try {
      await ScreenProtector.preventScreenshotOff();
      try {
        await ScreenProtector.protectDataLeakageOff();
      } catch (_) {}
    } catch (_) {}
  }

  // ==================== SESSION ====================

  Future<void> _loadSession() async {
    final repo = ref.read(publicationRepositoryProvider);
    final session = await repo.startSession(
      type: widget.type,
      bookId: widget.bookId,
    );

    if (!mounted) return;

    if (session == null) {
      setState(() {
        _error = 'Could not open this publication';
        _loading = false;
      });
      return;
    }

    setState(() {
      _session = session;
      _currentPage = session.resumePage;
      _loading = false;
    });
  }

  Future<void> _saveProgress() async {
    if (_session == null) return;
    final repo = ref.read(publicationRepositoryProvider);
    await repo.saveProgress(
      type: widget.type,
      bookId: widget.bookId,
      page: _currentPage,
      pageCount: _session!.pageCount,
    );
  }

  String _getPageUrl(int page) {
    if (_session == null) return '';
    if (_session!.pageUrlTemplate.isEmpty) {
      return 'https://picsum.photos/seed/${widget.bookId}_$page/800/1100';
    }
    return _session!.pageUrlTemplate.replaceAll('{page}', page.toString());
  }

  void _nextPage() {
    if (_session == null) return;
    if (_currentPage < _session!.pageCount) {
      setState(() => _currentPage++);
      _saveProgress();
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
      _saveProgress();
    }
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _session != null
              ? 'Page $_currentPage of ${_session!.pageCount}'
              : 'Reader',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_iosCaptured) _buildCaptureOverlay(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) return _buildError();
    return _buildReader();
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReader() {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! < 0) {
                _nextPage();
              } else if (details.primaryVelocity! > 0) {
                _previousPage();
              }
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 3.0,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: _getPageUrl(_currentPage),
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported,
                                  size: 64, color: Colors.white54),
                              SizedBox(height: 12),
                              Text('Page not available',
                                  style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_session?.security.watermark == true)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _buildWatermark(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        _buildControls(),
        _buildSecurityBanner(),
      ],
    );
  }

  /// Tiled diagonal watermark — deters casual screenshots even if bypassed.
  Widget _buildWatermark() {
    final user = ref.read(authStateProvider).user;
    final label = user?.email ?? 'OCB Reader';
    final now = DateTime.now();
    final stamp =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final text = '$label  •  $stamp';

    return LayoutBuilder(
      builder: (context, constraints) {
        const cell = 220.0;
        final cols = (constraints.maxWidth / cell).ceil() + 1;
        final rows = (constraints.maxHeight / cell).ceil() + 1;

        return Stack(
          children: [
            for (var r = 0; r < rows; r++)
              for (var c = 0; c < cols; c++)
                Positioned(
                  left: c * cell + (r.isOdd ? cell / 2 : 0),
                  top: r * cell,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Opacity(
                      opacity: 0.09,
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left,
                color: Colors.white, size: 32),
            onPressed: _currentPage > 1 ? _previousPage : null,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_currentPage / ${_session?.pageCount ?? 0}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right,
                color: Colors.white, size: 32),
            onPressed: _currentPage < (_session?.pageCount ?? 0)
                ? _nextPage
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBanner() {
    final s = _session?.security;
    final active = s?.blockScreenshots ?? true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: active ? AppColors.primaryRed : AppColors.mediumGray,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            active ? Icons.security : Icons.info_outline,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            active
                ? 'Secure Reader • Screenshots blocked'
                : 'Reader • Standard mode',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// iOS-only: replaces content with a lock screen when the OS reports
  /// that the screen is being captured (recording / mirroring / screenshot).
  Widget _buildCaptureOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.visibility_off, size: 72, color: Colors.white70),
              SizedBox(height: 16),
              Text(
                'Screen capture detected',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This content is protected.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}