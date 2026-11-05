// Lectura y edición segura de archivos .utoc (IoStore de Unreal Engine).
//
// Esta clase NO hace E/S de disco: trabaja sobre bytes en memoria para que
// sea fácil de probar y para que el servicio de parcheo pueda validar TODO
// antes de escribir nada.
//
// Layout del encabezado (little-endian) que usamos:
//   0   magic "-==--==--==--==-"  (16 bytes)
//   16  version (u8)
//   20  tocHeaderSize (u32)       -> normalmente 144
//   24  tocEntryCount (u32)       -> nº de chunks
//   28  compressedBlockEntryCount (u32)
//   44  compressionBlockSize (u32)
//   52  partitionCount (u32)
//   56  containerId (u64)
//   80  containerFlags (u8)       -> 0x02 = cifrado
//   84  perfectHashSeedsCount (u32)         (version >= 4)
//   96  chunksWithoutPerfectHashCount (u32) (version >= 5)
//
// Después del encabezado, en este orden:
//   chunkIds[entryCount]            12 bytes c/u (id u64 + índice u16 + pad + tipo)
//   chunkOffsetLengths[entryCount]  10 bytes c/u (offset u40 BE + length u40 BE)
//   perfectHashSeeds[...]           4 bytes c/u
//   chunksWithoutPerfectHash[...]   4 bytes c/u
//   compressionBlocks[blockCount]   12 bytes c/u

import 'dart:typed_data';

/// El .utoc no se puede interpretar, o no es seguro modificarlo.
class IoStoreException implements Exception {
  final String message;
  const IoStoreException(this.message);

  @override
  String toString() => message;
}

/// Dónde está (dentro del .ucas) el principio del ContainerHeader.
class ContainerHeaderLocation {
  /// Offset absoluto dentro del .ucas.
  final int ucasOffset;

  /// Cuántos bytes iniciales del header hay que inspeccionar.
  final int windowLength;

  const ContainerHeaderLocation(this.ucasOffset, this.windowLength);
}

class _BlockEntry {
  final int offset;
  final int compressedSize;
  final int uncompressedSize;
  final int methodIndex;

  const _BlockEntry(
      this.offset, this.compressedSize, this.uncompressedSize, this.methodIndex);
}

class IoStoreToc {
  static const int minHeaderSize = 144;
  static const int _chunkIdSize = 12;
  static const int _offsetLengthSize = 10;
  static const int _blockEntrySize = 12;
  static const int _containerIdOffset = 56;
  static const int _flagEncrypted = 0x02;
  static const String _magic = '-==--==--==--==-';

  final Uint8List _bytes;
  final ByteData _view;

  final int version;
  final int headerSize;
  final int entryCount;
  final int blockCount;
  final int compressionBlockSize;
  final int partitionCount;
  final int containerFlags;
  final int _seedCount;
  final int _noHashCount;

  /// ID del contenedor (se actualiza con [replaceContainerId]).
  int containerId;

  IoStoreToc._(
    this._bytes,
    this._view, {
    required this.version,
    required this.headerSize,
    required this.entryCount,
    required this.blockCount,
    required this.compressionBlockSize,
    required this.partitionCount,
    required this.containerFlags,
    required int seedCount,
    required int noHashCount,
    required this.containerId,
  })  : _seedCount = seedCount,
        _noHashCount = noHashCount;

  static bool _hasMagic(Uint8List b) {
    if (b.length < 16) return false;
    for (var i = 0; i < 16; i++) {
      if (b[i] != _magic.codeUnitAt(i)) return false;
    }
    return true;
  }

  /// Lee solo el ContainerId de los primeros [minHeaderSize] bytes.
  /// Útil para registrar IDs reservados (juego base) sin cargar TOCs enormes.
  static int peekContainerId(Uint8List head) {
    if (head.length < minHeaderSize || !_hasMagic(head)) {
      throw const IoStoreException('Not a valid .utoc header.');
    }
    return ByteData.sublistView(head)
        .getUint64(_containerIdOffset, Endian.little);
  }

  /// Parsea y VALIDA un .utoc completo. Trabaja sobre una copia de [source].
  factory IoStoreToc.parse(Uint8List source) {
    if (source.length < minHeaderSize) {
      throw IoStoreException(
          'File too small to be a .utoc (${source.length} bytes).');
    }
    if (!_hasMagic(source)) {
      throw const IoStoreException('Missing IoStore TOC magic: not a .utoc.');
    }

    final bytes = Uint8List.fromList(source);
    final view = ByteData.sublistView(bytes);

    final version = view.getUint8(16);
    final headerSize = view.getUint32(20, Endian.little);
    final entryCount = view.getUint32(24, Endian.little);
    final blockCount = view.getUint32(28, Endian.little);
    final blockSize = view.getUint32(44, Endian.little);
    final partitionCount = view.getUint32(52, Endian.little);
    final containerId = view.getUint64(_containerIdOffset, Endian.little);
    final flags = view.getUint8(80);
    final seeds = version >= 4 ? view.getUint32(84, Endian.little) : 0;
    final noHash = version >= 5 ? view.getUint32(96, Endian.little) : 0;

    if (headerSize < minHeaderSize || headerSize > bytes.length) {
      throw IoStoreException('Unexpected TOC header size: $headerSize.');
    }
    final tablesEnd =
        headerSize + entryCount * (_chunkIdSize + _offsetLengthSize);
    if (tablesEnd > bytes.length) {
      throw const IoStoreException(
          'Corrupt .utoc: chunk tables exceed the file size.');
    }

    return IoStoreToc._(
      bytes,
      view,
      version: version,
      headerSize: headerSize,
      entryCount: entryCount,
      blockCount: blockCount,
      compressionBlockSize: blockSize,
      partitionCount: partitionCount,
      containerFlags: flags,
      seedCount: seeds,
      noHashCount: noHash,
      containerId: containerId,
    );
  }

  Uint8List toBytes() => _bytes;

  // ---------------------------------------------------------------- chunks

  int _chunkIdOffset(int i) => headerSize + i * _chunkIdSize;

  /// Primeros 8 bytes del chunk ID (= Package ID en chunks de paquete).
  int chunkIdValue(int i) =>
      _view.getUint64(_chunkIdOffset(i), Endian.little);

  /// Índice del chunk "ContainerHeader": su ID es el propio ContainerId.
  int? findContainerHeaderChunk() {
    for (var i = 0; i < entryCount; i++) {
      if (chunkIdValue(i) == containerId) return i;
    }
    return null;
  }

  /// Package IDs del contenedor (sin el chunk del ContainerHeader).
  Set<int> packageIds() {
    final header = findContainerHeaderChunk();
    final ids = <int>{};
    for (var i = 0; i < entryCount; i++) {
      if (i != header) ids.add(chunkIdValue(i));
    }
    return ids;
  }

  // --------------------------------------------------------------- ubicar

  int _readUint40BE(int o) {
    var v = 0;
    for (var i = 0; i < 5; i++) {
      v = (v << 8) | _bytes[o + i];
    }
    return v;
  }

  int get _blocksStart =>
      headerSize +
      entryCount * (_chunkIdSize + _offsetLengthSize) +
      _seedCount * 4 +
      _noHashCount * 4;

  _BlockEntry _blockAt(int index) {
    final o = _blocksStart + index * _blockEntrySize;
    if (index < 0 || index >= blockCount || o + _blockEntrySize > _bytes.length) {
      throw const IoStoreException(
          'Compression block table is out of range.');
    }
    var offset = 0;
    for (var i = 4; i >= 0; i--) {
      offset = (offset << 8) | _bytes[o + i];
    }
    final compressed =
        _bytes[o + 5] | (_bytes[o + 6] << 8) | (_bytes[o + 7] << 16);
    final uncompressed =
        _bytes[o + 8] | (_bytes[o + 9] << 8) | (_bytes[o + 10] << 16);
    return _BlockEntry(offset, compressed, uncompressed, _bytes[o + 11]);
  }

  /// Calcula dónde empieza el ContainerHeader dentro del .ucas.
  ///
  /// Lanza [IoStoreException] si NO es seguro parchear (cifrado, comprimido,
  /// particionado...). En ese caso el llamador debe dejar el mod intacto:
  /// un parche a medias (TOC cambiado y .ucas no) es lo que hace crashear
  /// el juego.
  ContainerHeaderLocation locateContainerHeader() {
    if ((containerFlags & _flagEncrypted) != 0) {
      throw const IoStoreException('The container is encrypted.');
    }
    if (partitionCount > 1) {
      throw const IoStoreException('Multi-partition containers are not supported.');
    }
    if (compressionBlockSize <= 0) {
      throw const IoStoreException('Invalid compression block size.');
    }
    final chunk = findContainerHeaderChunk();
    if (chunk == null) {
      throw const IoStoreException(
          'The .utoc has no ContainerHeader chunk (unknown layout).');
    }

    final base = headerSize + entryCount * _chunkIdSize + chunk * _offsetLengthSize;
    final chunkOffset = _readUint40BE(base);
    final chunkLength = _readUint40BE(base + 5);

    final block = _blockAt(chunkOffset ~/ compressionBlockSize);
    if (block.methodIndex != 0) {
      throw const IoStoreException(
          'The ContainerHeader is compressed inside the .ucas.');
    }

    final inBlock = chunkOffset % compressionBlockSize;
    var window = chunkLength;
    if (block.uncompressedSize - inBlock < window) {
      window = block.uncompressedSize - inBlock;
    }
    if (window > 512) window = 512;
    if (window < 8) {
      throw const IoStoreException('ContainerHeader is too small.');
    }
    return ContainerHeaderLocation(block.offset + inBlock, window);
  }

  // --------------------------------------------------------------- editar

  /// Cambia el ContainerId en el encabezado Y en la tabla de chunks
  /// (el chunk del ContainerHeader se busca por este ID). Devuelve cuántas
  /// entradas de la tabla se actualizaron.
  int replaceContainerId(int newId) {
    final old = containerId;
    var updated = 0;
    for (var i = 0; i < entryCount; i++) {
      if (chunkIdValue(i) == old) {
        _view.setUint64(_chunkIdOffset(i), newId, Endian.little);
        updated++;
      }
    }
    _view.setUint64(_containerIdOffset, newId, Endian.little);
    containerId = newId;
    return updated;
  }
}