// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/ios_theme.dart';
import '../theme/app_metrics.dart';
import 'app_title_bar.dart' show WindowChrome;

// ============================================================================
//  ORIGEN DE LA TRANSICIÓN
// ============================================================================

/// Registro "ruta del mod -> GlobalKey de su portada". El panel de detalles
/// registra aquí la clave de su portada para que el visor sepa de qué
/// rectángulo de pantalla debe despegar la imagen.
final Map<String, GlobalKey> _galleryOrigins = <String, GlobalKey>{};

void registerGalleryOrigin(String modPath, GlobalKey key) {
  _galleryOrigins[modPath] = key;
}

/// `true` desde que se abre el visor hasta que termina de cerrarse (incluida
/// la animación de salida). El panel de detalles lo escucha para apagar su
/// desenfoque de fondo mientras queda tapado: repetir un desenfoque enorme en
/// cada fotograma es lo que más estorbaba a la animación y al zoom.
final ValueNotifier<bool> imageViewerActive = ValueNotifier<bool>(false);

Rect? _globalRectOf(GlobalKey? key) {
  final BuildContext? ctx = key?.currentContext;
  final RenderObject? ro = ctx?.findRenderObject();
  if (ro is! RenderBox || !ro.attached || !ro.hasSize) return null;
  return ro.localToGlobal(Offset.zero) & ro.size;
}

ImageProvider _providerFor(String source) => source.startsWith('http')
    ? NetworkImage(source)
    : FileImage(File(source)) as ImageProvider;

// ---- Vista previa --------------------------------------------------------
// Una captura 4K ocupa ~33 MB una vez decodificada. Moverla por la pantalla
// durante la animación (y decodificarla justo cuando arranca) es lo que hacía
// que se trabara. Por eso la animación usa una COPIA REDIMENSIONADA (como
// mucho 1920 px de ancho, ~8 MB) y la imagen a máxima resolución se carga
// cuando la animación ya terminó, entrando con un fundido.

const int _kPreviewMinWidth = 960;
const int _kPreviewMaxWidth = 1920;

/// Ancho (en píxeles) al que se decodifica la vista previa: el de la pantalla,
/// acotado. El alto sale solo, conservando la proporción.
int _previewWidthFor(BuildContext context) {
  final MediaQueryData mq = MediaQuery.of(context);
  return (mq.size.width * mq.devicePixelRatio)
      .clamp(_kPreviewMinWidth.toDouble(), _kPreviewMaxWidth.toDouble())
      .round();
}

/// Misma imagen, decodificada a [width] px. Igual `width` => misma clave en la
/// caché de imágenes de Flutter, así que lo que se precarga aquí lo reutilizan
/// después la animación y el visor sin volver a decodificar.
ImageProvider _previewProviderFor(String source, int width) =>
    ResizeImage(_providerFor(source), width: width);

/// Tamaño de la imagen (normalmente ya está en caché, tarda ~1 frame). Se pide
/// sobre la vista previa: decodificar la original entera solo para saber su
/// proporción era lo que retrasaba y trababa la apertura.
Future<Size?> _resolveSize(ImageProvider provider) {
  final Completer<Size?> c = Completer<Size?>();
  final ImageStream stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener l;
  l = ImageStreamListener(
    (ImageInfo info, bool _) {
      if (!c.isCompleted) {
        c.complete(
          Size(info.image.width.toDouble(), info.image.height.toDouble()),
        );
      }
      stream.removeListener(l);
    },
    onError: (Object _, StackTrace? __) {
      if (!c.isCompleted) c.complete(null);
      stream.removeListener(l);
    },
  );
  stream.addListener(l);
  return c.future.timeout(
    const Duration(milliseconds: 400),
    onTimeout: () => null,
  );
}

/// Deja la vista previa de [images][[initialIndex]] decodificada en la caché de
/// imágenes de Flutter ANTES de que el usuario pulse "maximizar". Así, la
/// primera vez que se abre el visor ya no hay que decodificar nada en ese
/// momento (ni esperar, ni decodificar mientras vuela la imagen). Hay que
/// llamarla con el mismo `context` (mismo tamaño de pantalla) que usará
/// [showImageViewer], para que la clave de la caché coincida.
Future<void> prewarmImageViewer(
  BuildContext context,
  List<String> images, {
  int initialIndex = 0,
}) async {
  if (images.isEmpty || !context.mounted) return;
  final int i = initialIndex.clamp(0, images.length - 1);
  await precacheImage(
    _previewProviderFor(images[i], _previewWidthFor(context)),
    context,
    onError: (Object _, StackTrace? __) {},
  );
}

// ============================================================================
//  API
// ============================================================================

/// Abre el visor a pantalla completa. La imagen se expande desde el rectángulo
/// de la portada ([modPath] registrado con [registerGalleryOrigin]) y vuelve a
/// él al cerrar; arrastrar hacia abajo también cierra.
Future<void> showImageViewer(
  BuildContext context, {
  required List<String> images,
  int initialIndex = 0,
  String? modPath,
  String closeTooltip = 'Close',
}) async {
  final NavigatorState nav = Navigator.of(context, rootNavigator: true);

  // Rectángulo de la portada en coordenadas del Navigator.
  Rect? origin;
  final Rect? global = _globalRectOf(modPath == null ? null : _galleryOrigins[modPath]);
  final RenderObject? navBox = nav.context.findRenderObject();
  if (global != null && navBox is RenderBox && navBox.hasSize) {
    origin = Rect.fromPoints(
      navBox.globalToLocal(global.topLeft),
      navBox.globalToLocal(global.bottomRight),
    );
  }

  // La vista previa se decodifica ANTES de abrir: así, al arrancar la
  // animación, la imagen ya está lista en la caché y no hay nada que decodificar
  // mientras vuela.
  final int previewWidth = _previewWidthFor(context);
  final Size? imageSize = await _resolveSize(
    _previewProviderFor(images[initialIndex], previewWidth),
  );
  if (!nav.mounted) return;

  final PageRouteBuilder<void> route = PageRouteBuilder<void>(
    opaque: false,
    barrierDismissible: false,
    transitionDuration: const Duration(milliseconds: 560),
    reverseTransitionDuration: const Duration(milliseconds: 440),
    pageBuilder: (_, __, ___) => ImageViewerPage(
      images: images,
      initialIndex: initialIndex,
      origin: origin,
      initialImageSize: imageSize,
      previewWidth: previewWidth,
      closeTooltip: closeTooltip,
    ),
    transitionsBuilder: (_, __, ___, child) => child,
  );

  imageViewerActive.value = true;
  unawaited(nav.push<void>(route));

  // El desenfoque del panel se reactiva al EMPEZAR a cerrar, no al terminar:
  // mientras el fondo negro del visor aún es casi opaco el cambio no se ve, y
  // cuando se desvanece el panel ya tiene su aspecto normal. Si se esperase al
  // final, durante todo el cierre se vería el panel translúcido y sin
  // desenfoque, y al acabar daría un salto.
  route.animation?.addStatusListener((AnimationStatus status) {
    if (status == AnimationStatus.reverse) imageViewerActive.value = false;
  });

  try {
    // `completed` espera a que termine también la animación de cierre (el
    // Future de push se resuelve al EMPEZAR a cerrar).
    await route.completed;
  } finally {
    imageViewerActive.value = false;
  }
}

// ============================================================================
//  PÁGINA DEL VISOR
// ============================================================================

// Despegue rápido y asentamiento largo (estilo iOS).
const Cubic _kOut = Cubic(0.16, 1.0, 0.3, 1.0);

class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.previewWidth,
    this.origin,
    this.initialImageSize,
    this.closeTooltip = 'Close',
  });

  final List<String> images;
  final int initialIndex;
  final Rect? origin;

  /// Tamaño de la vista previa de la imagen inicial (la proporción es la de la
  /// imagen original).
  final Size? initialImageSize;

  /// Ancho de decodificación de las vistas previas (ver [_previewWidthFor]).
  final int previewWidth;
  final String closeTooltip;

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage>
    with TickerProviderStateMixin {
  late final PageController _pages;
  late int _index;
  final FocusNode _focus = FocusNode();

  bool _controlsVisible = true;
  bool _zoomed = false;

  // La imagen a máxima resolución solo se pide cuando la animación de apertura
  // terminó: decodificarla (y subir ~33 MB a la GPU) durante el vuelo era el
  // tirón.
  bool _fullEnabled = false;
  Timer? _fullTimer;
  bool _transitionHooked = false;
  Animation<double>? _routeAnimation;

  // Arrastre vertical para descartar.
  double _dragDy = 0;
  late final AnimationController _snapBack;
  Animation<double>? _snapAnim;

  double get _dragProgress => (_dragDy.abs() / 320).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pages = PageController(initialPage: widget.initialIndex);
    _snapBack = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_transitionHooked) return;
    _transitionHooked = true;

    final Animation<double>? animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _enableFull());
    } else {
      _routeAnimation = animation;
      animation.addStatusListener(_onRouteStatus);
    }
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _enableFull();
  }

  void _enableFull() {
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _routeAnimation = null;
    if (_fullEnabled || _fullTimer != null || !mounted) return;
    // Un respiro tras el asentamiento: justo al terminar la animación ya se
    // están pintando por primera vez los controles de cristal (desenfoque).
    // Si además se pedía aquí la imagen de ~33 MB y las vecinas, todo caía en
    // el mismo fotograma y se notaba el tirón.
    _fullTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() => _fullEnabled = true);
      _precacheNeighbours();
    });
  }

  /// Deja listas las vistas previas de las imágenes vecinas (son ligeras) para
  /// que al pasar de página se vean al instante.
  void _precacheNeighbours() {
    for (final int i in <int>[_index - 1, _index + 1]) {
      if (i < 0 || i >= widget.images.length) continue;
      precacheImage(
        _previewProviderFor(widget.images[i], widget.previewWidth),
        context,
        onError: (Object _, StackTrace? __) {},
      );
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _fullTimer?.cancel();
    _snapBack.dispose();
    _pages.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _close() {
    if (mounted) Navigator.of(context).maybePop();
  }

  void _go(int delta) {
    final int target = (_index + delta).clamp(0, widget.images.length - 1);
    if (target == _index) return;
    _pages.animateToPage(
      target,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_zoomed) return;
    _snapBack.stop();
    setState(() => _dragDy += d.delta.dy);
  }

  void _onDragEnd(DragEndDetails d) {
    if (_zoomed) return;
    final double v = d.velocity.pixelsPerSecond.dy;
    if (_dragDy.abs() > 120 || v.abs() > 900) {
      _close();
      return;
    }
    final double from = _dragDy;
    _snapAnim = Tween<double>(begin: from, end: 0).animate(
      CurvedAnimation(parent: _snapBack, curve: Curves.easeOutBack),
    )..addListener(() {
        if (mounted) setState(() => _dragDy = _snapAnim!.value);
      });
    _snapBack
      ..reset()
      ..forward();
  }

  /// Alto que ocupa la barra de la ventana fusionada con la de herramientas.
  /// La imagen no debe invadirlo: se reserva ese espacio arriba (0 si la barra
  /// no está fusionada, porque entonces el visor ya empieza debajo de ella).
  double get _topInset => WindowChrome.merged.value ? WindowChrome.barHeight : 0.0;

  /// Rectángulo de la imagen ajustada (contain) dentro del área visible, es
  /// decir, la pantalla menos el espacio de la barra superior.
  Rect _targetRect(Size screen) {
    final double top = _topInset.clamp(0.0, screen.height);
    final Rect area = Rect.fromLTWH(0, top, screen.width, screen.height - top);
    final Size? s = widget.initialImageSize;
    if (s == null || s.isEmpty) return area;
    final Size fitted = applyBoxFit(BoxFit.contain, s, area.size).destination;
    return Rect.fromLTWH(
      area.left + (area.width - fitted.width) / 2,
      area.top + (area.height - fitted.height) / 2,
      fitted.width,
      fitted.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> route =
        ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(1.0);

    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (_, KeyEvent e) {
        if (e is! KeyDownEvent) return KeyEventResult.ignored;
        if (e.logicalKey == LogicalKeyboardKey.escape) {
          _close();
          return KeyEventResult.handled;
        }
        if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _go(-1);
          return KeyEventResult.handled;
        }
        if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
          _go(1);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Material(
        type: MaterialType.transparency,
        child: LayoutBuilder(
          builder: (context, box) {
            final Size screen = box.biggest;
            // El visor (PageView + imágenes) se construye UNA vez por cambio
            // de estado y se pasa como `child`: los fotogramas de la
            // animación solo recolocan capas, no lo reconstruyen.
            final Widget pager = _buildPager();
            return AnimatedBuilder(
              animation: route,
              child: pager,
              builder: (context, pagerChild) =>
                  _buildLayers(route, screen, pagerChild!),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLayers(Animation<double> route, Size screen, Widget pager) {
    final double v = route.value.clamp(0.0, 1.0);
    final bool animating = route.status == AnimationStatus.forward ||
        route.status == AnimationStatus.reverse;
    final bool reversing = route.status == AnimationStatus.reverse;

    // Posición eased: despegue rápido al abrir; al cerrar, la curva espejada
    // para que también arranque rápido y se asiente en la portada.
    final double e = reversing ? 1.0 - _kOut.transform(1.0 - v) : _kOut.transform(v);

    // Solo se vuela si seguimos en la imagen de origen y sin zoom.
    final bool canFly = _index == widget.initialIndex && !_zoomed;
    final bool flying = animating && canFly;

    final double dragBg = 1.0 - _dragProgress * 0.85;
    final double bgOpacity = 0.96 * Curves.easeOut.transform(v) * dragBg;

    // Los widgets de esta lista mantienen SIEMPRE su posición (el hueco del
    // vuelo se rellena con un SizedBox): si cambiaran de posición Flutter
    // reconstruiría el visor y los controles al terminar la animación.
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Colors.black.withOpacity(bgOpacity)),

        // Visor interactivo (oculto mientras vuela la imagen).
        Opacity(
          opacity: flying ? 0.0 : (animating ? v : 1.0),
          child: Transform.scale(
            scale: animating && !canFly ? lerpDouble(0.92, 1.0, e)! : 1.0,
            child: pager,
          ),
        ),

        flying ? _buildFlight(screen, e) : const SizedBox.shrink(),

        // Controles: aparecen cuando la imagen ya llegó a su sitio (y se van
        // en cuanto empieza a cerrarse). Con fundido durante el vuelo habría
        // que mezclar cristales con desenfoque sobre una imagen en movimiento.
        AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: (_controlsVisible && !animating ? 1.0 : 0.0) *
              (1.0 - _dragProgress),
          child: IgnorePointer(
            ignoring: !_controlsVisible || animating,
            child: _buildControls(),
          ),
        ),
      ],
    );
  }

  /// Imagen en vuelo entre la portada y su posición final. Usa la vista previa
  /// (ya decodificada y pequeña), nunca la imagen a máxima resolución.
  Widget _buildFlight(Size screen, double e) {
    final Rect target = _targetRect(screen);
    final Rect? origin = widget.origin;
    final Rect from = origin ?? target.deflate(target.shortestSide * 0.05);
    final Rect rect = Rect.lerp(from, target, e)!;

    // El arrastre previo al cierre se desvanece conforme la imagen vuela.
    final double drag = _dragDy * e;
    final double dragScale = 1.0 - _dragProgress * 0.28 * e;

    final double radius = lerpDouble(origin != null ? 14.0 : 0.0, 0.0, e.clamp(0.0, 1.0))!;

    Widget img = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image(
        image: _previewProviderFor(widget.images[_index], widget.previewWidth),
        fit: BoxFit.cover,
        // Misma calidad que la capa de vista previa del visor, para que el
        // relevo entre una y otra al llegar no se note.
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
      ),
    );
    if (origin == null) {
      img = Opacity(opacity: (e * 2.5).clamp(0.0, 1.0), child: img);
    }

    return Positioned.fromRect(
      rect: rect.shift(Offset(0, drag)),
      child: Transform.scale(scale: dragScale, child: img),
    );
  }

  Widget _buildPager() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      onTap: () => setState(() => _controlsVisible = !_controlsVisible),
      child: Transform.translate(
        offset: Offset(0, _dragDy),
        child: Transform.scale(
          scale: 1.0 - _dragProgress * 0.28,
          // Capa propia: mover/escalar al arrastrar solo recoloca la imagen ya
          // pintada, sin volver a pintarla.
          child: RepaintBoundary(
            // Deja libre el espacio de la barra fusionada y recorta ahí la
            // imagen (el zoom, que no recorta por sí solo, tampoco la invade).
            child: Padding(
              padding: EdgeInsets.only(top: _topInset),
              child: ClipRect(
                child: PageView.builder(
                  controller: _pages,
                  itemCount: widget.images.length,
                  physics: _zoomed
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  onPageChanged: (i) {
                    setState(() {
                      _index = i;
                      _zoomed = false;
                    });
                    _precacheNeighbours();
                  },
                  itemBuilder: (context, i) => _ZoomablePage(
                    key: ValueKey<String>('page-$i-${widget.images[i]}'),
                    preview: _previewProviderFor(
                      widget.images[i],
                      widget.previewWidth,
                    ),
                    full: _providerFor(widget.images[i]),
                    loadFull: _fullEnabled,
                    onZoomChanged: (z) {
                      if (z != _zoomed) setState(() => _zoomed = z);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    final int total = widget.images.length;
    // Con la barra fusionada y los botones de la ventana a la derecha
    // (minimizar / maximizar / cerrar flotan sobre el visor), el botón de
    // cerrar del visor se coloca justo DEBAJO de ellos para no superponerse.
    final bool underWindowButtons = WindowChrome.rightInset > 0;
    final double closeTop =
        underWindowButtons ? WindowChrome.barHeight + 8 : 14;
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: closeTop,
            right: 14,
            child: _GlassCircle(
              tooltip: widget.closeTooltip,
              onTap: _close,
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          if (total > 1)
            Positioned(
              top: 18,
              left: 0,
              right: 0,
              child: Center(child: _GlassPillLabel('${_index + 1} / $total')),
            ),
          if (total > 1 && _index > 0)
            Positioned(
              left: 14,
              top: 0,
              bottom: 0,
              child: Center(
                child: _GlassCircle(
                  onTap: () => _go(-1),
                  child: const Icon(Icons.chevron_left_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
            ),
          if (total > 1 && _index < total - 1)
            Positioned(
              right: 14,
              top: 0,
              bottom: 0,
              child: Center(
                child: _GlassCircle(
                  onTap: () => _go(1),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
//  IMAGEN CON ZOOM
// ============================================================================

class _ZoomablePage extends StatefulWidget {
  const _ZoomablePage({
    super.key,
    required this.preview,
    required this.full,
    required this.loadFull,
    required this.onZoomChanged,
  });

  /// Copia redimensionada: se ve al instante (ya está en caché).
  final ImageProvider preview;

  /// Imagen original, a máxima resolución.
  final ImageProvider full;

  /// Si es false todavía no se pide la imagen a máxima resolución (la
  /// animación de apertura sigue en marcha).
  final bool loadFull;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<_ZoomablePage>
    with TickerProviderStateMixin {
  final TransformationController _tc = TransformationController();
  late final AnimationController _anim;
  Animation<Matrix4>? _matrixAnim;
  Offset _doubleTapAt = Offset.zero;

  // Fundido de entrada de la imagen a máxima resolución sobre la vista previa.
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;
  bool _fullShown = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _tc.addListener(_notify);
  }

  void _notify() {
    if (!mounted) return;
    widget.onZoomChanged(_tc.value.getMaxScaleOnAxis() > 1.02);
  }

  @override
  void dispose() {
    _tc.removeListener(_notify);
    _tc.dispose();
    _anim.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _animateTo(Matrix4 end) {
    _matrixAnim = Matrix4Tween(begin: _tc.value, end: end).animate(
      CurvedAnimation(parent: _anim, curve: _kOut),
    )..addListener(() => _tc.value = _matrixAnim!.value);
    _anim
      ..reset()
      ..forward();
  }

  void _onDoubleTap() {
    if (_tc.value.getMaxScaleOnAxis() > 1.02) {
      _animateTo(Matrix4.identity());
    } else {
      const double z = 2.5;
      final Offset p = _doubleTapAt;
      _animateTo(
        Matrix4.identity()
          ..translate(-p.dx * (z - 1), -p.dy * (z - 1))
          ..scale(z),
      );
    }
  }

  /// Se llama cuando la imagen a máxima resolución termina de decodificarse:
  /// entonces (y solo entonces) empieza el fundido sobre la vista previa.
  Widget _onFullFrame(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (frame != null && !_fullShown) {
      _fullShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (wasSynchronouslyLoaded) {
          _fadeCtrl.value = 1.0; // ya estaba en caché: sin fundido
        } else {
          _fadeCtrl.forward();
        }
      });
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _doubleTapAt = d.localPosition,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _tc,
        minScale: 1.0,
        maxScale: 5.0,
        clipBehavior: Clip.none,
        // Las dos capas ocupan EXACTAMENTE el mismo rectángulo (pantalla
        // completa + contain, misma proporción), así que al aparecer la de
        // máxima resolución no se mueve nada: solo gana nitidez.
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: widget.preview,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white38,
                    size: 48,
                  ),
                ),
              ),
              if (widget.loadFull)
                Image(
                  image: widget.full,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                  // Opacidad animada directamente en el pintado de la imagen
                  // (sin capa intermedia de transparencia).
                  opacity: _fade,
                  frameBuilder: _onFullFrame,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
//  CONTROLES DE CRISTAL
// ============================================================================

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.child, required this.onTap, this.tooltip});
  final Widget child;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget w = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: AppMetrics.md ? AppMetrics.iconButton : 38,
              height: AppMetrics.md ? AppMetrics.iconButton : 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x55222222),
                border: Border.all(color: IosColors.overlay(0x22), width: 0.5),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? w : Tooltip(message: tooltip!, child: w);
  }
}

class _GlassPillLabel extends StatelessWidget {
  const _GlassPillLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: const Color(0x55222222),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}