import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/features/live/domain/models/incubator_models.dart';

/// Foto tray inkubator dengan overlay bounding box hasil deteksi YOLO.
///
/// Koordinat `box` dari backend memakai piksel citra asli (mis. 1600x1200),
/// jadi widget ini mengambil ukuran asli citra lebih dulu lalu menggambar
/// box dengan skala yang sama seperti gambar yang ditampilkan.
class LiveDetectionImage extends StatefulWidget {
  const LiveDetectionImage({
    super.key,
    required this.image,
    this.detections = const [],
    this.fit = BoxFit.contain,
    this.semanticLabel = 'Foto tray inkubator',
  });

  /// Sumber foto tray (URL jaringan atau base64).
  final IncubatorImage image;

  /// Hasil deteksi YOLO yang akan digambar sebagai bounding box.
  final List<EggDetection> detections;

  /// Cara gambar diposisikan di dalam kotak yang tersedia.
  final BoxFit fit;

  /// Label aksesibilitas untuk gambar.
  final String semanticLabel;

  @override
  State<LiveDetectionImage> createState() => _LiveDetectionImageState();
}

class _LiveDetectionImageState extends State<LiveDetectionImage> {
  ImageProvider? _provider;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  Size? _imageSize;
  Object? _error;
  String? _imageKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncImage();
  }

  @override
  void didUpdateWidget(covariant LiveDetectionImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_keyFor(oldWidget.image) != _keyFor(widget.image)) {
      _syncImage();
    }
  }

  @override
  void dispose() {
    _detachStream();
    super.dispose();
  }

  String? _keyFor(IncubatorImage image) {
    if (image.isEmpty) return null;
    return image.isNetwork
        ? 'network:${image.networkUrl}'
        : 'memory:${image.base64Data}';
  }

  void _syncImage() {
    final key = _keyFor(widget.image);
    if (key == _imageKey) return;
    _imageKey = key;
    _detachStream();
    _imageSize = null;
    _error = null;

    if (key == null) {
      _provider = null;
      return;
    }

    final ImageProvider provider;
    if (widget.image.isNetwork) {
      provider = NetworkImage(widget.image.networkUrl!);
    } else {
      try {
        provider = MemoryImage(base64Decode(widget.image.base64Data!));
      } catch (error) {
        _provider = null;
        _error = error;
        return;
      }
    }
    _provider = provider;

    final listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        final size = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );
        if (size != _imageSize) {
          setState(() => _imageSize = size);
        }
      },
      onError: (error, stackTrace) {
        if (mounted) setState(() => _error = error);
      },
    );
    _listener = listener;
    _stream = provider.resolve(createLocalImageConfiguration(context))
      ..addListener(listener);
  }

  void _detachStream() {
    final stream = _stream;
    final listener = _listener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _stream = null;
    _listener = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.image.isEmpty) return const SizedBox.shrink();
    if (_error != null) return const _ImagePlaceholder();

    final provider = _provider;
    if (provider == null) return const _ImagePlaceholder();

    final imageSize = _imageSize;
    if (imageSize == null) {
      return Image(
        image: provider,
        fit: widget.fit,
        semanticLabel: widget.semanticLabel,
        errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
      );
    }

    final detected = widget.detections
        .where((detection) => detection.hasBox)
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth ||
            !constraints.hasBoundedHeight ||
            constraints.maxWidth <= 0 ||
            constraints.maxHeight <= 0) {
          return Center(
            child: AspectRatio(
              aspectRatio: imageSize.width / imageSize.height,
              child: _buildImageStack(
                provider: provider,
                imageSize: imageSize,
                detected: detected,
                imageRect: null,
              ),
            ),
          );
        }

        final fitted = applyBoxFit(widget.fit, imageSize, constraints.biggest);
        final imageRect = Alignment.center.inscribe(
          fitted.destination,
          Offset.zero & constraints.biggest,
        );

        return _buildImageStack(
          provider: provider,
          imageSize: imageSize,
          detected: detected,
          imageRect: imageRect,
        );
      },
    );
  }

  Widget _buildImageStack({
    required ImageProvider provider,
    required Size imageSize,
    required List<EggDetection> detected,
    required Rect? imageRect,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: provider,
          fit: widget.fit,
          semanticLabel: widget.semanticLabel,
        ),
        if (detected.isNotEmpty)
          CustomPaint(
            key: const ValueKey('egg-detection-overlay'),
            painter: EggDetectionPainter(
              imageSize: imageSize,
              detections: detected,
              imageRect: imageRect,
            ),
          ),
      ],
    );
  }
}

/// Pelukis bounding box telur di atas citra tray.
class EggDetectionPainter extends CustomPainter {
  EggDetectionPainter({
    required this.imageSize,
    required this.detections,
    this.imageRect,
  });

  /// Ukuran asli citra dalam piksel.
  final Size imageSize;

  /// Deteksi dengan koordinat box valid.
  final List<EggDetection> detections;

  /// Area citra yang tampil di kanvas (hasil `BoxFit`); null = seluruh kanvas.
  final Rect? imageRect;

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.isEmpty || size.isEmpty) return;

    final target = imageRect ?? (Offset.zero & size);
    if (target.isEmpty) return;
    final scaleX = target.width / imageSize.width;
    final scaleY = target.height / imageSize.height;
    final strokeWidth = (target.shortestSide * 0.008).clamp(1.5, 3.0);
    final fontSize = (target.shortestSide * 0.04).clamp(9.0, 12.0);

    canvas.save();
    canvas.clipRect(target);
    for (final detection in detections) {
      final rect = Rect.fromLTWH(
        target.left + detection.x * scaleX,
        target.top + detection.y * scaleY,
        detection.width * scaleX,
        detection.height * scaleY,
      ).intersect(target);
      if (rect.isEmpty) continue;

      final color = detection.isCracked
          ? AppColors.statusOffline
          : AppColors.statusConnected;

      canvas.drawRect(
        rect,
        Paint()
          ..color = color.withValues(alpha: 0.12)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );

      _paintLabel(
        canvas: canvas,
        bounds: target,
        box: rect,
        color: color,
        fontSize: fontSize,
        text: detection.displayLabel,
      );
    }
    canvas.restore();
  }

  void _paintLabel({
    required Canvas canvas,
    required Rect bounds,
    required Rect box,
    required Color color,
    required double fontSize,
    required String text,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: bounds.width);

    final horizontalPadding = fontSize * 0.45;
    final verticalPadding = fontSize * 0.2;
    final labelWidth = textPainter.width + horizontalPadding * 2;
    final labelHeight = textPainter.height + verticalPadding * 2;

    var left = box.left;
    var top = box.top - labelHeight - 2;
    if (top < bounds.top) top = box.top + 2;
    if (top + labelHeight > bounds.bottom) {
      top = bounds.bottom - labelHeight;
    }
    if (left + labelWidth > bounds.right) {
      left = bounds.right - labelWidth;
    }
    if (left < bounds.left) left = bounds.left;
    if (top < bounds.top) top = bounds.top;

    final badge = Rect.fromLTWH(left, top, labelWidth, labelHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(badge, Radius.circular(fontSize * 0.35)),
      Paint()..color = color,
    );
    textPainter.paint(
      canvas,
      Offset(left + horizontalPadding, top + verticalPadding),
    );
  }

  @override
  bool shouldRepaint(covariant EggDetectionPainter oldDelegate) {
    return imageSize != oldDelegate.imageSize ||
        imageRect != oldDelegate.imageRect ||
        !listEquals(detections, oldDelegate.detections);
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.candlingDarkDeep,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textSlateLight,
          size: 28,
        ),
      ),
    );
  }
}
