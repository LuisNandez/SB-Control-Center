import 'dart:io';
import 'package:flutter/material.dart';
import '../../thumbnail_service.dart';
import 'ios_widgets.dart' show IosSpinner;

class ModImage extends StatelessWidget {
  final String imageUrl;
  final bool isLocal;
  final DateTime? lastModified;
  final BoxFit fit;
  final double? height;

  /// Si es true, la imagen se decodifica al tamaño con el que se va a mostrar
  /// (según el ancho disponible y la densidad de pantalla) en vez de a su
  /// resolución original. Una captura 4K ocupa ~33 MB una vez decodificada y
  /// tarda en decodificarse: hacerlo así evita el tirón al abrir el panel.
  final bool decodeToLayout;

  /// Miniatura ya disponible (la que la lista tiene en caché). Se muestra al
  /// instante mientras llega la imagen completa, que aparece con un fundido.
  final File? placeholder;

  const ModImage({
    super.key,
    required this.imageUrl,
    this.isLocal = false,
    this.lastModified,
    this.fit = BoxFit.cover,
    this.height,
    this.decodeToLayout = false,
    this.placeholder,
  });

  /// Fundido de entrada cuando la imagen termina de decodificarse. Si ya
  /// estaba en la caché de imágenes de Flutter se muestra sin animación.
  static Widget _fadeIn(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      child: child,
    );
  }

  Widget _buildImage(BuildContext context, int? cacheWidth) {
    const Widget broken = Icon(Icons.broken_image, size: 50, color: Colors.grey);

    if (isLocal) {
      return Image.file(
        File(imageUrl),
        key: ValueKey(lastModified),
        height: height,
        width: double.infinity,
        fit: fit,
        cacheWidth: cacheWidth,
        filterQuality: FilterQuality.medium,
        frameBuilder: _fadeIn,
        errorBuilder: (context, error, stackTrace) => broken,
      );
    }
    return Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: fit,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.medium,
      frameBuilder: _fadeIn,
      loadingBuilder: (context, child, loadingProgress) {
        // Con miniatura de fondo no hace falta spinner.
        if (loadingProgress == null || placeholder != null) return child;
        return const Center(child: IosSpinner(radius: 12));
      },
      errorBuilder: (context, error, stackTrace) => broken,
    );
  }

  @override
  Widget build(BuildContext context) {
    final File? thumb = placeholder;

    Widget content(int? cacheWidth) {
      final Widget image = _buildImage(context, cacheWidth);
      if (thumb == null) return image;
      return Stack(
        fit: StackFit.passthrough,
        children: [
          Image.file(
            thumb,
            height: height,
            width: double.infinity,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          image,
        ],
      );
    }

    if (!decodeToLayout) return content(null);

    return LayoutBuilder(
      builder: (context, constraints) {
        int? cacheWidth;
        if (constraints.maxWidth.isFinite) {
          final double dpr = MediaQuery.devicePixelRatioOf(context);
          // Un 25 % de margen por si la imagen es más panorámica que su marco.
          cacheWidth = (constraints.maxWidth * dpr * 1.25).round();
        }
        return content(cacheWidth);
      },
    );
  }
}

class ModThumbnailImage extends StatefulWidget {
  final String? imageUrl;
  final String? imagePathToProcess;
  final ThumbnailService thumbnailService;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isLocal;
  final Alignment alignment;

  const ModThumbnailImage({
    super.key,
    required this.imageUrl,
    this.imagePathToProcess,
    required this.thumbnailService,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.isLocal = false,
    this.alignment = Alignment.center,
  });

  @override
  State<ModThumbnailImage> createState() => _ModThumbnailImageState();
}

class _ModThumbnailImageState extends State<ModThumbnailImage> {
  File? _imageFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant ModThumbnailImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl ||
        widget.imagePathToProcess != oldWidget.imagePathToProcess) {
      _resolve();
    }
  }

  /// Si la miniatura ya está en memoria se usa en el mismo fotograma (sin
  /// pasar por el spinner): al volver hacia arriba en la lista las tarjetas se
  /// recrean y así no parpadean. Si no, se carga en segundo plano.
  void _resolve() {
    final String? cacheKey = widget.imageUrl;
    final String? sourcePath = widget.imagePathToProcess;

    if (cacheKey == null || sourcePath == null) {
      _imageFile = null;
      _isLoading = false;
      return;
    }

    final File? cachedFile = widget.thumbnailService.getFromMemoryCache(
      cacheKey,
    );
    if (cachedFile != null) {
      _imageFile = cachedFile;
      _isLoading = false;
      return;
    }

    _imageFile = null;
    _isLoading = true;
    _loadImage(cacheKey, sourcePath);
  }

  Future<void> _loadImage(String cacheKey, String sourcePath) async {
    File? file;
    try {
      file = await widget.thumbnailService.getThumbnail(
        cacheKey,
        sourcePath,
        isLocalFile: widget.isLocal,
      );
    } catch (_) {
      file = null;
    }
    // Si mientras tanto la tarjeta pasó a mostrar otra imagen, se descarta.
    if (!mounted || widget.imageUrl != cacheKey) return;
    setState(() {
      _imageFile = file;
      _isLoading = false;
    });
  }

  Widget _fallback() => Container(
    width: widget.width,
    height: widget.height,
    color: Colors.black26,
    child: const Icon(Icons.extension, size: 60, color: Colors.white38),
  );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: IosSpinner(radius: 10));
    }

    final File? file = _imageFile;
    if (file != null) {
      // Sin existsSync(): comprobar el disco en cada build bloquea la UI al
      // hacer scroll. Si el archivo no existe, errorBuilder pinta el icono.
      //
      // Las miniaturas generadas ya son pequeñas y se decodifican tal cual.
      // Si falló la reducción y llega el ORIGINAL (puede ser un 4K de ~33 MB
      // decodificado), se limita el ancho de decodificación para proteger la RAM.
      return Image.file(
        file,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        cacheWidth:
            widget.thumbnailService.isGeneratedThumbnail(file) ? null : 800,
        gaplessPlayback: true,
        frameBuilder: ModImage._fadeIn,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }

    return _fallback();
  }
}

class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;

  /// Radio de las esquinas superiores del marco (0 = recto).
  final double topRadius;

  CropOverlayPainter({required this.cropRect, this.topRadius = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.6);
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final frame = RRect.fromRectAndCorners(
      cropRect,
      topLeft: Radius.circular(topRadius),
      topRight: Radius.circular(topRadius),
    );

    final backgroundPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(frame),
    );
    canvas.drawPath(backgroundPath, backgroundPaint);

    canvas.drawRRect(frame, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! CropOverlayPainter ||
        oldDelegate.cropRect != cropRect ||
        oldDelegate.topRadius != topRadius;
  }
}