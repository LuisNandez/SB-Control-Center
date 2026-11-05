import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

/// Estado de endorse de un mod tal como se guarda en su `nexus_info.json`.
class EndorseRecord {
  static const String statusKey = 'endorseStatus';
  static const String checkedAtKey = 'endorseCheckedAt';

  /// 'Endorsed' | 'Abstained' | 'Undecided'.
  final String status;

  /// Cuándo se confirmó este estado con Nexus (o cuándo lo cambió el usuario).
  final DateTime checkedAt;

  const EndorseRecord(this.status, this.checkedAt);

  bool get isEndorsed => status == 'Endorsed';

  /// ¿Se confirmó hace menos de [ttl]? Una fecha en el futuro (reloj cambiado)
  /// se considera caducada.
  bool isFresh(Duration ttl) {
    final Duration age = DateTime.now().difference(checkedAt);
    return !age.isNegative && age < ttl;
  }

  /// Normaliza el texto de estado de Nexus. null si no es un valor conocido
  /// (así un dato ausente nunca se confunde con "no endorsado").
  static String? normalize(Object? raw) {
    switch (raw?.toString().trim().toLowerCase()) {
      case 'endorsed':
        return 'Endorsed';
      case 'abstained':
        return 'Abstained';
      case 'undecided':
        return 'Undecided';
      default:
        return null;
    }
  }

  /// Lee el registro del contenido ya decodificado de un nexus_info.json.
  static EndorseRecord? fromInfo(Object? data) {
    if (data is! Map) return null;
    final String? status = normalize(data[statusKey]);
    final DateTime? at = DateTime.tryParse(data[checkedAtKey]?.toString() ?? '');
    if (status == null || at == null) return null;
    return EndorseRecord(status, at);
  }

  /// Escribe el registro en [data] (el mapa de un nexus_info.json).
  void applyTo(Map<String, dynamic> data) {
    data[statusKey] = status;
    data[checkedAtKey] = checkedAt.toIso8601String();
  }
}

/// Lee y escribe el estado de endorse dentro del `nexus_info.json` de cada mod.
/// El archivo del mod es la ÚNICA fuente guardada: no hay caché en memoria ni
/// en preferencias que pueda quedar desfasada.
class EndorseInfoStore {
  /// Escrituras en curso por carpeta: se ejecutan una detrás de otra para que
  /// dos cambios seguidos del mismo mod no se pisen entre sí.
  static final Map<String, Future<void>> _queues = {};

  static File _file(Directory dir) => File(p.join(dir.path, 'nexus_info.json'));

  /// Registro guardado en la carpeta del mod, o null si no hay.
  static Future<EndorseRecord?> read(Directory dir) async {
    try {
      final File file = _file(dir);
      if (!await file.exists()) return null;
      final String text = await file.readAsString();
      if (text.trim().isEmpty) return null;
      return EndorseRecord.fromInfo(json.decode(text));
    } catch (e) {
      print('No se pudo leer el endorse de ${p.basename(dir.path)}: $e');
      return null;
    }
  }

  /// Guarda [status] en el nexus_info.json del mod, conservando el resto de
  /// claves. NO crea el archivo si no existe ni toca uno que no se pueda leer.
  /// Devuelve true si se escribió.
  static Future<bool> write(
    Directory dir,
    String status, {
    DateTime? checkedAt,
  }) {
    final String key = dir.path;
    final DateTime at = checkedAt ?? DateTime.now();

    final Future<bool> job = (_queues[key] ?? Future<void>.value())
        .then((_) => _writeNow(dir, status, at));
    final Future<void> tail = job.then((_) {}, onError: (_) {});
    _queues[key] = tail;
    tail.whenComplete(() {
      if (identical(_queues[key], tail)) _queues.remove(key);
    });
    return job;
  }

  /// Guarda el mismo estado en el nexus_info.json de varias carpetas (p. ej.
  /// todas las ediciones instaladas de un mismo mod: en Nexus el endorse es por
  /// mod, no por archivo). Cada carpeta usa su propia cola de escritura.
  static Future<void> writeAll(
    Iterable<Directory> dirs,
    String status, {
    DateTime? checkedAt,
  }) async {
    final DateTime at = checkedAt ?? DateTime.now();
    await Future.wait(dirs.map((d) => write(d, status, checkedAt: at)));
  }

  static Future<bool> _writeNow(
    Directory dir,
    String status,
    DateTime checkedAt,
  ) async {
    try {
      final File file = _file(dir);
      if (!await file.exists()) return false;
      final String text = await file.readAsString();
      if (text.trim().isEmpty) return false;
      final Object? decoded = json.decode(text);
      if (decoded is! Map) return false;

      final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);
      EndorseRecord(status, checkedAt).applyTo(data);
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      return true;
    } catch (e) {
      print('No se pudo guardar el endorse en ${p.basename(dir.path)}: $e');
      return false;
    }
  }
}