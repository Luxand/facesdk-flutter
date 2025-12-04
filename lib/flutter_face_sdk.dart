import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'utils.dart' show getDynamicLibrary;

final _nativeLib = getDynamicLibrary('facesdk', libShortName: 'fsdk', iOSStatic: true);

enum ImageMode {
  Grayscale8bit,
  Color24bit,
  Color32bit
}

enum VideoCompressionType {
  MJPEG
}

class Error implements Exception {

  static const Ok = 0;
  static const Failed = -1;
  static const NotActivated = -2;
  static const OutOfMemory = -3;
  static const InvalidArgument = -4;
  static const IoError = -5;
  static const ImageTooSmall = -6;
  static const FaceNotFound = -7;
  static const InsufficientBufferSize = -8;
  static const UnsupportedImageExtension = -9;
  static const CannotOpenFile = -10;
  static const CannotCreateFile = -11;
  static const BadFileFormat = -12;
  static const FileNotFound = -13;
  static const ConnectionClosed = -14;
  static const ConnectionFailed = -15;
  static const IpInitFailed = -16;
  static const NeedServerActivation = -17;
  static const IdNotFound = -18;
  static const AttributeNotDetected = -19;
  static const InsufficientTrackerMemoryLimit = -20;
  static const UnknownAttribute = -21;
  static const UnsupportedFileVersion = -22;
  static const SyntaxError = -23;
  static const ParameterNotFound = -24;
  static const InvalidTemplate = -25;
  static const UnsupportedTemplateVersion = -26;
  static const CameraIndexDoesNotExist = -27;
  static const PlatformNotLicensed = -28;
  static const TensorflowNotInitialized = -29;
  static const PluginNotLoaded = -30;
  static const PluginNoPermission = -31;
  static const FaceIDNotFound = -32;
  static const FaceImageNotFound = -33;

  final int _code;
  final Object? _info;
  final String _callee;

  Error(int code, String callee, [Object? info]) : _code = code, _callee = callee, _info = info;

  int get code => _code;

  String get callee => _callee;

  Object? get info => _info;

}

class FailedError extends Error {
  FailedError(String callee, [Object? info]) : super(Error.Failed, callee, info);
}

class NotActivatedError extends Error {
  NotActivatedError(String callee, [Object? info]) : super(Error.NotActivated, callee, info);
}

class OutOfMemoryError extends Error {
  OutOfMemoryError(String callee, [Object? info]) : super(Error.OutOfMemory, callee, info);
}

class InvalidArgumentError extends Error {
  InvalidArgumentError(String callee, [Object? info]) : super(Error.InvalidArgument, callee, info);
}

class IoError extends Error {
  IoError(String callee, [Object? info]) : super(Error.IoError, callee, info);
}

class ImageTooSmallError extends Error {
  ImageTooSmallError(String callee, [Object? info]) : super(Error.ImageTooSmall, callee, info);
}

class FaceNotFoundError extends Error {
  FaceNotFoundError(String callee, [Object? info]) : super(Error.FaceNotFound, callee, info);
}

class InsufficientBufferSizeError extends Error {
  InsufficientBufferSizeError(String callee, [Object? info]) : super(Error.InsufficientBufferSize, callee, info);
}

class UnsupportedImageExtensionError extends Error {
  UnsupportedImageExtensionError(String callee, [Object? info]) : super(Error.UnsupportedImageExtension, callee, info);
}

class CannotOpenFileError extends Error {
  CannotOpenFileError(String callee, [Object? info]) : super(Error.CannotOpenFile, callee, info);
}

class CannotCreateFileError extends Error {
  CannotCreateFileError(String callee, [Object? info]) : super(Error.CannotCreateFile, callee, info);
}

class BadFileFormatError extends Error {
  BadFileFormatError(String callee, [Object? info]) : super(Error.BadFileFormat, callee, info);
}

class FileNotFoundError extends Error {
  FileNotFoundError(String callee, [Object? info]) : super(Error.FileNotFound, callee, info);
}

class ConnectionClosedError extends Error {
  ConnectionClosedError(String callee, [Object? info]) : super(Error.ConnectionClosed, callee, info);
}

class ConnectionFailedError extends Error {
  ConnectionFailedError(String callee, [Object? info]) : super(Error.ConnectionFailed, callee, info);
}

class IpInitFailedError extends Error {
  IpInitFailedError(String callee, [Object? info]) : super(Error.IpInitFailed, callee, info);
}

class NeedServerActivationError extends Error {
  NeedServerActivationError(String callee, [Object? info]) : super(Error.NeedServerActivation, callee, info);
}

class IdNotFoundError extends Error {
  IdNotFoundError(String callee, [Object? info]) : super(Error.IdNotFound, callee, info);
}

class AttributeNotDetectedError extends Error {
  AttributeNotDetectedError(String callee, [Object? info]) : super(Error.AttributeNotDetected, callee, info);
}

class InsufficientTrackerMemoryLimitError extends Error {
  InsufficientTrackerMemoryLimitError(String callee, [Object? info]) : super(Error.InsufficientTrackerMemoryLimit, callee, info);
}

class UnknownAttributeError extends Error {
  UnknownAttributeError(String callee, [Object? info]) : super(Error.UnknownAttribute, callee, info);
}

class UnsupportedFileVersionError extends Error {
  UnsupportedFileVersionError(String callee, [Object? info]) : super(Error.UnsupportedFileVersion, callee, info);
}

class SyntaxError extends Error {
  SyntaxError(String callee, [Object? info]) : super(Error.SyntaxError, callee, info);
}

class ParameterNotFoundError extends Error {
  ParameterNotFoundError(String callee, [Object? info]) : super(Error.ParameterNotFound, callee, info);
}

class InvalidTemplateError extends Error {
  InvalidTemplateError(String callee, [Object? info]) : super(Error.InvalidTemplate, callee, info);
}

class UnsupportedTemplateVersionError extends Error {
  UnsupportedTemplateVersionError(String callee, [Object? info]) : super(Error.UnsupportedTemplateVersion, callee, info);
}

class CameraIndexDoesNotExistError extends Error {
  CameraIndexDoesNotExistError(String callee, [Object? info]) : super(Error.CameraIndexDoesNotExist, callee, info);
}

class PlatformNotLicensedError extends Error {
  PlatformNotLicensedError(String callee, [Object? info]) : super(Error.PlatformNotLicensed, callee, info);
}

class TensorflowNotInitializedError extends Error {
  TensorflowNotInitializedError(String callee, [Object? info]) : super(Error.TensorflowNotInitialized, callee, info);
}

class PluginNotLoadedError extends Error {
  PluginNotLoadedError(String callee, [Object? info]) : super(Error.PluginNotLoaded, callee, info);
}

class PluginNoPermissionError extends Error {
  PluginNoPermissionError(String callee, [Object? info]) : super(Error.PluginNoPermission, callee, info);
}

class FaceIDNotFoundError extends Error {
  FaceIDNotFoundError(String callee, [Object? info]) : super(Error.FaceIDNotFound, callee, info);
}

class FaceImageNotFoundError extends Error {
  FaceImageNotFoundError(String callee, [Object? info]) : super(Error.FaceImageNotFound, callee, info);
}

final _ErrorTypes = {
  Error.Failed: (String callee, [Object? info]) => FailedError(callee, info),
  Error.NotActivated: (String callee, [Object? info]) => NotActivatedError(callee, info),
  Error.OutOfMemory: (String callee, [Object? info]) => OutOfMemoryError(callee, info),
  Error.InvalidArgument: (String callee, [Object? info]) => InvalidArgumentError(callee, info),
  Error.IoError: (String callee, [Object? info]) => IoError(callee, info),
  Error.ImageTooSmall: (String callee, [Object? info]) => ImageTooSmallError(callee, info),
  Error.FaceNotFound: (String callee, [Object? info]) => FaceNotFoundError(callee, info),
  Error.InsufficientBufferSize: (String callee, [Object? info]) => InsufficientBufferSizeError(callee, info),
  Error.UnsupportedImageExtension: (String callee, [Object? info]) => UnsupportedImageExtensionError(callee, info),
  Error.CannotOpenFile: (String callee, [Object? info]) => CannotOpenFileError(callee, info),
  Error.CannotCreateFile: (String callee, [Object? info]) => CannotCreateFileError(callee, info),
  Error.BadFileFormat: (String callee, [Object? info]) => BadFileFormatError(callee, info),
  Error.FileNotFound: (String callee, [Object? info]) => FileNotFoundError(callee, info),
  Error.ConnectionClosed: (String callee, [Object? info]) => ConnectionClosedError(callee, info),
  Error.ConnectionFailed: (String callee, [Object? info]) => ConnectionFailedError(callee, info),
  Error.IpInitFailed: (String callee, [Object? info]) => IpInitFailedError(callee, info),
  Error.NeedServerActivation: (String callee, [Object? info]) => NeedServerActivationError(callee, info),
  Error.IdNotFound: (String callee, [Object? info]) => IdNotFoundError(callee, info),
  Error.AttributeNotDetected: (String callee, [Object? info]) => AttributeNotDetectedError(callee, info),
  Error.InsufficientTrackerMemoryLimit: (String callee, [Object? info]) => InsufficientTrackerMemoryLimitError(callee, info),
  Error.UnknownAttribute: (String callee, [Object? info]) => UnknownAttributeError(callee, info),
  Error.UnsupportedFileVersion: (String callee, [Object? info]) => UnsupportedFileVersionError(callee, info),
  Error.SyntaxError: (String callee, [Object? info]) => SyntaxError(callee, info),
  Error.ParameterNotFound: (String callee, [Object? info]) => ParameterNotFoundError(callee, info),
  Error.InvalidTemplate: (String callee, [Object? info]) => InvalidTemplateError(callee, info),
  Error.UnsupportedTemplateVersion: (String callee, [Object? info]) => UnsupportedTemplateVersionError(callee, info),
  Error.CameraIndexDoesNotExist: (String callee, [Object? info]) => CameraIndexDoesNotExistError(callee, info),
  Error.PlatformNotLicensed: (String callee, [Object? info]) => PlatformNotLicensedError(callee, info),
  Error.TensorflowNotInitialized: (String callee, [Object? info]) => TensorflowNotInitializedError(callee, info),
  Error.PluginNotLoaded: (String callee, [Object? info]) => PluginNotLoadedError(callee, info),
  Error.PluginNoPermission: (String callee, [Object? info]) => PluginNoPermissionError(callee, info),
  Error.FaceIDNotFound: (String callee, [Object? info]) => FaceIDNotFoundError(callee, info),
  Error.FaceImageNotFound: (String callee, [Object? info]) => FaceImageNotFoundError(callee, info)
};

const FacialFeatureCount = 70;


class Freeable {

  void free() {}

}

class _NativePointer<T extends NativeType> extends Freeable {

  final bool _owner;
  final Pointer<T> pointer;

  _NativePointer(this.pointer, [this._owner = false]);

  factory _NativePointer.fromAddress(int address) {
    return _NativePointer(Pointer<T>.fromAddress(address));
  }

  factory _NativePointer.allocate(int count) {
    return _NativePointer(malloc.allocate<T>(count), true);
  }

  @override
  void free() {
    if (_owner) {
      malloc.free(pointer);
    }
  }
}

class _AutoNativePointer<T extends NativeType> extends _NativePointer<T> {

  final Finalizer<Pointer<T>> _finalizer = Finalizer((pointer) => malloc.free(pointer));

  _AutoNativePointer(Pointer<T> pointer) : super(pointer) {
    _finalizer.attach(this, pointer, detach: this);
  }

  factory _AutoNativePointer.allocate(int count) {
    return _AutoNativePointer(malloc.allocate<T>(count));
  }

  @override
  void free() {
    _finalizer.detach(this);
    super.free();
  }
}

class BufferInfo {

  final int _dataAddress;
  final int _lengthAddress;

  BufferInfo(this._dataAddress, this._lengthAddress);

}

class DataBuffer extends ListBase<int> implements Freeable {

  late Uint8List _data;
  late _NativePointer<Int32> _length;
  late _NativePointer<Uint8> _nativeData;

  DataBuffer.allocate(int length) {
    _length = _AutoNativePointer<Int32>.allocate(sizeOf<Int32>())..pointer.value = length;
    _nativeData = _AutoNativePointer<Uint8>.allocate(sizeOf<Uint8>() * length);
    _data = _nativeData.pointer.asTypedList(length);
  }

  factory DataBuffer._allocate(int length) {
    return DataBuffer.allocate(length);
  }

  DataBuffer.fromPointers(Pointer<Uint8> nativeData, Pointer<Int32> length) {
    _length = _NativePointer<Int32>(length);
    _nativeData = _NativePointer<Uint8>(nativeData);
    _data = _nativeData.pointer.asTypedList(_length.pointer.value);
  }

  DataBuffer.fromAddresses(int nativeDataAddress, int lengthAddress) {
    _length = _NativePointer<Int32>.fromAddress(lengthAddress);
    _nativeData = _NativePointer<Uint8>.fromAddress(nativeDataAddress);
    _data = _nativeData.pointer.asTypedList(_length.pointer.value);
  }

  factory DataBuffer.fromInfo(BufferInfo info) {
    return DataBuffer.fromAddresses(info._dataAddress, info._lengthAddress);
  }

  factory DataBuffer.fromByteBuffer(ByteBuffer buffer) {
    final result = DataBuffer.allocate(buffer.lengthInBytes);
    result._data.setRange(0, buffer.lengthInBytes, buffer.asUint8List());
    return result;
  }

  int get capacity => _data.length;
  @override
  int get length => _length.pointer.value;

  @override
  set length(int newLength) {
    if (newLength <= capacity) {
      _length.pointer.value = newLength;
      return;
    }

    if (!_nativeData._owner) {
      throw UnsupportedError("Cannot reallocate non owned pointers");
    }

    final newNativeData = _AutoNativePointer<Uint8>.allocate(sizeOf<Uint8>() * newLength);
    final newData = newNativeData.pointer.asTypedList(newLength);
    newData.setRange(0, length, _data);

    _nativeData.free();

    _data = newData;
    _nativeData = newNativeData;
    _length.pointer.value = newLength;
  }

  Pointer<Uint8> get pointer => _nativeData.pointer;
  Pointer<Int32> get _lengthPointer => _length.pointer;

  @override
  int operator [](int index) => _data[index];
  @override
  void operator []=(int index, int value) => _data[index] = value;

  BufferInfo getInfo() {
    return BufferInfo(pointer.address, _lengthPointer.address);
  }

  Uint8List asUint8List() {
    return Uint8List.fromList(_data);
  }

  @override
  void free() {
    _nativeData.free();
    _length.free();
  }
}

class Int64Buffer extends ListBase<int> implements Freeable {

  late Int64List _data;
  late _NativePointer<Int64> _length;
  late _NativePointer<Int64> _nativeData;

  Int64Buffer.allocate(int length) {
    _length = _AutoNativePointer<Int64>.allocate(sizeOf<Int64>())..pointer.value = length;
    _nativeData = _AutoNativePointer<Int64>.allocate(sizeOf<Int64>() * length);
    _data = _nativeData.pointer.asTypedList(length);
  }

  factory Int64Buffer._allocate(int length) {
    return Int64Buffer.allocate(length);
  }

  Int64Buffer.fromPointers(Pointer<Int64> nativeData, Pointer<Int64> length) {
    _length = _NativePointer<Int64>(length);
    _nativeData = _NativePointer<Int64>(nativeData);
    _data = _nativeData.pointer.asTypedList(_length.pointer.value);
  }

  Int64Buffer.fromAddresses(int nativeDataAddress, int lengthAddress) {
    _length = _NativePointer<Int64>.fromAddress(lengthAddress);
    _nativeData = _NativePointer<Int64>.fromAddress(nativeDataAddress);
    _data = _nativeData.pointer.asTypedList(_length.pointer.value);
  }

  factory Int64Buffer.fromInfo(BufferInfo info) {
    return Int64Buffer.fromAddresses(info._dataAddress, info._lengthAddress);
  }

  factory Int64Buffer.fromByteBuffer(ByteBuffer buffer) {
    final length = buffer.lengthInBytes ~/ sizeOf<Int64>();
    final result = Int64Buffer.allocate(length);
    result._data.setRange(0, length, buffer.asInt64List());
    return result;
  }

  int get capacity => _data.length;
  @override
  int get length => _length.pointer.value;

  @override
  set length(int newLength) {
    if (newLength <= capacity) {
      _length.pointer.value = newLength;
      return;
    }

    if (!_nativeData._owner) {
      throw UnsupportedError("Cannot reallocate non owned pointers");
    }

    final newNativeData = _AutoNativePointer<Int64>.allocate(sizeOf<Int64>() * newLength);
    final newData = newNativeData.pointer.asTypedList(newLength);
    newData.setRange(0, length, _data);

    _nativeData.free();

    _data = newData;
    _nativeData = newNativeData;
    _length.pointer.value = newLength;
  }

  Pointer<Int64> get pointer => _nativeData.pointer;
  Pointer<Int64> get _lengthPointer => _length.pointer;

  @override
  int operator [](int index) => _data[index];
  @override
  void operator []=(int index, int value) => _data[index] = value;

  BufferInfo getInfo() {
    return BufferInfo(pointer.address, _lengthPointer.address);
  }

  Int64List asInt64List() {
    return Int64List.fromList(_data);
  }

  @override
  void free() {
    _nativeData.free();
    _length.free();
  }
}

class _FacePosition extends Struct {

  @Int32()
  external int xc;

  @Int32()
  external int yc;

  @Int32()
  external int w;

  @Int32()
  external int padding;

  @Double()
  external double angle;

}

class FacePosition extends Freeable {

  final _NativePointer<_FacePosition> _nativePointer;

  Pointer<_FacePosition> get pointer => _nativePointer.pointer;

  int get xc => pointer.ref.xc;
  int get yc => pointer.ref.yc;
  int get w  => pointer.ref.w;

  set xc(int value) => pointer.ref.xc = value;
  set yc(int value) => pointer.ref.yc = value;
  set  w(int value) => pointer.ref.w  = value;

  double get angle => pointer.ref.angle;
  set angle(double value) => pointer.ref.angle = value;

  FacePosition(this._nativePointer);

  factory FacePosition.allocate() {
    return FacePosition(_AutoNativePointer<_FacePosition>.allocate(sizeOf<_FacePosition>()));
  }

  factory FacePosition._allocate() {
    return FacePosition.allocate();
  }

  factory FacePosition.fromPointer(Pointer<_FacePosition> pointer) {
    return FacePosition(_NativePointer<_FacePosition>(pointer));
  }

  @override
  void free() {
    _nativePointer.free();
  }
}

class FacePositions extends ListBase<FacePosition> implements Freeable {

  late int _capacity;
  late _NativePointer<Int32> _length;
  late _NativePointer<_FacePosition> _nativeData;

  FacePositions.allocate(int length) {
    _capacity = length;
    _length = _AutoNativePointer<Int32>.allocate(sizeOf<Int32>())..pointer.value = length;
    _nativeData = _AutoNativePointer<_FacePosition>.allocate(sizeOf<_FacePosition>() * length);
  }

  factory FacePositions._allocate(int length) {
    return FacePositions.allocate(length);
  }

  FacePositions.fromPointers(Pointer<_FacePosition> nativeData, Pointer<Int32> length) {
    _length = _NativePointer<Int32>(length);
    _nativeData = _NativePointer<_FacePosition>(nativeData);
    _capacity = this.length;
  }

  FacePositions.fromAddresses(int nativeDataAddress, int lengthAddress) {
    _length = _NativePointer<Int32>.fromAddress(lengthAddress);
    _nativeData = _NativePointer<_FacePosition>.fromAddress(nativeDataAddress);
    _capacity = length;
  }

  factory FacePositions.fromInfo(BufferInfo info) {
    return FacePositions.fromAddresses(info._dataAddress, info._lengthAddress);
  }

  int get capacity => _capacity;
  @override
  int get length => _length.pointer.value;
  Pointer<_FacePosition> get pointer => _nativeData.pointer;
  Pointer<Int32> get _lengthPointer => _length.pointer;

  @override
  set length(int newLength) {
    if (newLength <= _capacity) {
      _length.pointer.value = newLength;
      return;
    }

    if (!_nativeData._owner) {
      throw UnsupportedError("Cannot reallocate non owned pointers");
    }

    final newNativeData = _AutoNativePointer<_FacePosition>.allocate(sizeOf<_FacePosition>() * newLength);
    for (int i = 0; i < min(length, newLength); ++i) {
      _assign(newNativeData.pointer[i], _nativeData.pointer[i]);
    }

    _nativeData.free();

    _nativeData = newNativeData;
    _length.pointer.value = newLength;
    _capacity = newLength;
  }

  void _assign(_FacePosition a, _FacePosition b) {
    a.xc = b.xc;
    a.yc = b.yc;
    a.w = b.w;
    a.padding = b.padding;
    a.angle = b.angle;
  }

  @override
  FacePosition operator [](int index) => FacePosition.fromPointer(pointer.elementAt(index));

  @override
  void operator []=(int index, FacePosition pos) => _assign(_nativeData.pointer[index], pos.pointer.ref);

  BufferInfo getInfo() {
    return BufferInfo(_nativeData.pointer.address, _length.pointer.address);
  }

  @override
  void free() {
    _length.free();
    _nativeData.free();
  }
}

class Point extends Struct {

  @Int32()
  external int x;

  @Int32()
  external int y;

  static Pointer<Point> allocate({required int x, required int y}) {
    final p = malloc<Point>();
    p.ref.x = x;
    p.ref.y = y;
    return p;
  }
}

class FeaturePoints extends Struct {
  @Array(5)
  external Array<Point> points;
}

class BBox extends Struct {
  external Point p0, p1;
}

class _Face extends Struct {
  external BBox bbox;
  external FeaturePoints features;
}

class Face extends Freeable {

  final _NativePointer<_Face> _nativePointer;

  BBox get bbox => _nativePointer.pointer.ref.bbox;
  FeaturePoints get features => _nativePointer.pointer.ref.features;

  Face(this._nativePointer);

  factory Face.allocate() {
    return Face(_AutoNativePointer<_Face>.allocate(sizeOf<_Face>()));
  }

  factory Face._allocate() {
    return Face.allocate();
  }

  factory Face.fromPointer(Pointer<_Face> pointer) {
    return Face(_NativePointer<_Face>(pointer));
  }

  factory Face.fromAddress(int address) {
    return Face(_NativePointer<_Face>.fromAddress(address));
  }

  Pointer<_Face> get pointer => _nativePointer.pointer;

  int get witdth => (bbox.p1.x - bbox.p1.x);  
  int get height => (bbox.p1.y - bbox.p0.y);
  int get left => bbox.p0.x;
  int get top => bbox.p0.y;
  int get right => bbox.p1.x;
  int get bottom => bbox.p1.y;

  set left(int value) => bbox.p0.x = value;
  set top(int value) => bbox.p0.y = value;
  set right(int value) => bbox.p1.x = value;
  set bottom(int value) => bbox.p1.y = value;

  set features(FeaturePoints value) => _nativePointer.pointer.ref.features = value;

  Pointer<Point> center() {
    int cx = ((bbox.p0.x + bbox.p1.x) ~/ 2).toInt();
    int cy = ((bbox.p0.y + bbox.p1.y) ~/ 2).toInt();
    return Point.allocate(x: cx, y:cy);
  }

  @override
  void free() {
    _nativePointer.free();
  }
}

class Faces extends ListBase<Face> implements Freeable {

  late int _capacity;
  late _NativePointer<Int32> _length;
  late _NativePointer<_Face> _nativeData;

  Faces.allocate(int length) {
    _capacity = length;
    _length = _AutoNativePointer<Int32>.allocate(sizeOf<Int32>())..pointer.value = length;
    _nativeData = _AutoNativePointer<_Face>.allocate(sizeOf<_Face>() * length);
  }

  factory Faces._allocate(int length) {
    return Faces.allocate(length);
  }

  Faces.fromPointers(Pointer<_Face> nativeData, Pointer<Int32> length) {
    _length = _NativePointer<Int32>(length);
    _nativeData = _NativePointer<_Face>(nativeData);
    _capacity = this.length;
  }

  Faces.fromAddresses(int nativeDataAddress, int lengthAddress) {
    _length = _NativePointer<Int32>.fromAddress(lengthAddress);
    _nativeData = _NativePointer<_Face>.fromAddress(nativeDataAddress);
    _capacity = length;
  }

  factory Faces.fromInfo(BufferInfo info) {
    return Faces.fromAddresses(info._dataAddress, info._lengthAddress);
  }

  int get capacity => _capacity;

  void _assign(_Face face1, _Face face2) {
    face1.bbox.p0 = face2.bbox.p0;
    face1.bbox.p1 = face2.bbox.p1;

    final points1 = face1.features.points;
    final points2 = face2.features.points;
    for (var i = 0; i < 5; i++) {
      points1[i].x = points2[i].x;
      points1[i].y = points2[i].y;
    }
  }
  
  @override
  int get length => _length.pointer.value;
  Pointer<_Face> get pointer => _nativeData.pointer;
  Pointer<Int32> get _lengthPointer => _length.pointer;

  @override
  set length(int newLength) {
    if (newLength <= _capacity) {
      _length.pointer.value = newLength;
      return;
    }

    if (!_nativeData._owner) {
      throw ArgumentError('Cannot set length of unowned Faces');
    }

    final newNativeData = _AutoNativePointer<_Face>.allocate(sizeOf<_Face>() * newLength);
    for (int i = 0; i < min(length, newLength); i++) {
      _assign(newNativeData.pointer[i], _nativeData.pointer[i]);
    }

    _nativeData.free();
    _nativeData = newNativeData;
    _capacity = newLength;
    _length.pointer.value = newLength;
  }

  @override
  Face operator [](int index) {
    return Face.fromPointer(pointer.elementAt(index));
  }

  @override
  void operator []=(int index, Face pos) => _assign(_nativeData.pointer[index], pos.pointer.ref);

  BufferInfo getInfo() {
    return BufferInfo(_nativeData.pointer.address, _length.pointer.address);
  }

  @override
  void free() {
    _length.free();
    _nativeData.free();
  }
}

class Eyes extends Freeable {

  final _NativePointer<Point> _nativePointer;

  Eyes(this._nativePointer);

  factory Eyes.allocate() {
    return Eyes(_AutoNativePointer.allocate(sizeOf<Point>() * 2));
  }

  factory Eyes._allocate() {
    return Eyes.allocate();
  }

  factory Eyes.fromPointer(Pointer<Point> pointer) {
    return Eyes(_NativePointer<Point>(pointer));
  }

  factory Eyes.fromAddress(int address) {
    return Eyes(_NativePointer<Point>.fromAddress(address));
  }

  Pointer<Point> get pointer => _nativePointer.pointer;

  Point get left => pointer[0];
  Point get right => pointer[1];

  set left(Point point) => _setPoint(0, point);
  set right(Point point) => _setPoint(1, point);

  void _setPoint(int index, Point point) {
    final value = pointer[index];
    value.x = point.x;
    value.y = point.y;
  }

  @override
  void free() {
    _nativePointer.free();
  }

}

class FacialFeatures extends ListBase<Point> implements Freeable {

  static const LeftEye = 0;
  static const RightEye = 1;
  static const NoseTip = 2;
  static const MouthRightCorner = 3;
  static const MouthLeftCorner = 4;
  static const FaceContour2 = 5;
  static const FaceContour12 = 6;
  static const FaceContour1 = 7;
  static const FaceContour13 = 8;
  static const ChinLeft = 9;
  static const ChinRight = 10;
  static const ChinBottom = 11;
  static const LeftEyebrowOuterCorner = 12;
  static const LeftEyebrowInnerCorner = 13;
  static const RightEyebrowInnerCorner = 14;
  static const RightEyebrowOuterCorner = 15;
  static const LeftEyebrowMiddle = 16;
  static const RightEyebrowMiddle = 17;
  static const LeftEyebrowMiddleLeft = 18;
  static const LeftEyebrowMiddleRight = 19;
  static const RightEyebrowMiddleLeft = 20;
  static const RightEyebrowMiddleRight = 21;
  static const NoseBridge = 22;
  static const LeftEyeOuterCorner = 23;
  static const LeftEyeInnerCorner = 24;
  static const RightEyeInnerCorner = 25;
  static const RightEyeOuterCorner = 26;
  static const LeftEyeLowerLine2 = 27;
  static const LeftEyeUpperLine2 = 28;
  static const LeftEyeLeftIrisCorner = 29;
  static const LeftEyeRightIrisCorner = 30;
  static const RightEyeLowerLine2 = 31;
  static const RightEyeUpperLine2 = 32;
  static const RightEyeLeftIrisCorner = 33;
  static const RightEyeRightIrisCorner = 34;
  static const LeftEyeUpperLine1 = 35;
  static const LeftEyeUpperLine3 = 36;
  static const LeftEyeLowerLine3 = 37;
  static const LeftEyeLowerLine1 = 38;
  static const RightEyeUpperLine3 = 39;
  static const RightEyeUpperLine1 = 40;
  static const RightEyeLowerLine1 = 41;
  static const RightEyeLowerLine3 = 42;
  static const NoseLeftWing = 43;
  static const NoseRightWing = 44;
  static const NoseLeftWingOuter = 45;
  static const NoseRightWingOuter = 46;
  static const NoseLeftWingLower = 47;
  static const NoseRightWingLower = 48;
  static const NoseBottom = 49;
  static const NasolabialFoldLeftUpper = 50;
  static const NasolabialFoldRightUpper = 51;
  static const NasolabialFoldLeftLower = 52;
  static const NasolabialFoldRightLower = 53;
  static const MouthTop = 54;
  static const MouthBottom = 55;
  static const MouthLeftTop = 56;
  static const MouthRightTop = 57;
  static const MouthLeftBottom = 58;
  static const MouthRightBottom = 59;
  static const MouthLeftTopInner = 60;
  static const MouthTopInner = 61;
  static const MouthRightTopInner = 62;
  static const MouthLeftBottomInner = 63;
  static const MouthBottomInner = 64;
  static const MouthRightBottomInner = 65;
  static const FaceContour14 = 66;
  static const FaceContour15 = 67;
  static const FaceContour16 = 68;
  static const FaceContour17 = 69;

  _NativePointer<Point> _nativePointer;

  FacialFeatures(this._nativePointer);

  factory FacialFeatures.allocate() {
    return FacialFeatures(_AutoNativePointer<Point>.allocate(sizeOf<Point>() * FacialFeatureCount));
  }

  factory FacialFeatures._allocate() {
    return FacialFeatures.allocate();
  }

  factory FacialFeatures.fromPointer(Pointer<Point> pointer) {
    return FacialFeatures(_NativePointer<Point>(pointer));
  }

  factory FacialFeatures.fromAddress(int address) {
    return FacialFeatures(_NativePointer<Point>.fromAddress(address));
  }

  @override
  int get length => FacialFeatureCount;

  @override
  set length(int newLength) {
    throw UnsupportedError('Cannot resize FacialFeatures object');
  }

  Pointer<Point> get pointer => _nativePointer.pointer;

  @override
  Point operator [](int index) => pointer[index];

  @override
  void operator []=(int index, Point point) {
    final value = pointer[index];
    value.x = point.x;
    value.y = point.y;
  }

  Eyes get eyes => Eyes.fromPointer(pointer);

  @override
  void free() {
    _nativePointer.free();
  }

}

class FaceTemplate extends Freeable {

  final DataBuffer _buffer;

  FaceTemplate(this._buffer);

  factory FaceTemplate.allocate() {
    return FaceTemplate(DataBuffer.allocate(1040));
  }

  factory FaceTemplate._allocate() {
    return FaceTemplate.allocate();
  }

  DataBuffer get buffer => _buffer;
  Pointer<Uint8> get pointer => _buffer.pointer;

  double match(FaceTemplate other) {
    return MatchFaces(this, other);
  }

  @override
  void free() {
    _buffer.free();
  }

}

class ExtractedFace {

  final Image image;
  final FacialFeatures features;

  ExtractedFace(this.image, this.features);

}

class IDSimilarity extends Struct {
  @Int64()
  external int id;

  @Float()
  external double similarity;
}

class IDSimilarities extends ListBase<IDSimilarity> implements Freeable {

  late int _capacity;
  late _NativePointer<Int64> _length;
  late _NativePointer<IDSimilarity> _nativeData;

  IDSimilarities.allocate(int length) {
    _capacity = length;
    _length = _AutoNativePointer<Int64>.allocate(sizeOf<Int64>())..pointer.value = length;
    _nativeData = _AutoNativePointer<IDSimilarity>.allocate(sizeOf<IDSimilarity>() * length);
  }

  factory IDSimilarities._allocate(int length) {
    return IDSimilarities.allocate(length);
  }

  IDSimilarities.fromPointers(Pointer<IDSimilarity> nativeData, Pointer<Int64> length) {
    _length = _NativePointer<Int64>(length);
    _nativeData = _NativePointer<IDSimilarity>(nativeData);
    _capacity = this.length;
  }

  IDSimilarities.fromAddresses(int nativeDataAddress, int lengthAddress) {
    _length = _NativePointer<Int64>.fromAddress(lengthAddress);
    _nativeData = _NativePointer<IDSimilarity>.fromAddress(nativeDataAddress);
    _capacity = length;
  }

  factory IDSimilarities.fromInfo(BufferInfo info) {
    return IDSimilarities.fromAddresses(info._dataAddress, info._lengthAddress);
  }

  int get capacity => _capacity;
  @override
  int get length => _length.pointer.value;
  Pointer<IDSimilarity> get pointer => _nativeData.pointer;
  Pointer<Int64> get _lengthPointer => _length.pointer;

  @override
  set length(int newLength) {
    if (newLength <= _capacity) {
      _length.pointer.value = newLength;
      return;
    }

    if (!_nativeData._owner) {
      throw UnsupportedError("Cannot reallocate non owned pointers");
    }

    final newNativeData = _AutoNativePointer<IDSimilarity>.allocate(sizeOf<IDSimilarity>() * newLength);
    for (int i = 0; i < min(length, newLength); ++i) {
      _assign(newNativeData.pointer[i], _nativeData.pointer[i]);
    }

    _nativeData.free();

    _nativeData = newNativeData;
    _length.pointer.value = newLength;
    _capacity = newLength;
  }

  void _assign(IDSimilarity a, IDSimilarity b) {
    a.id = b.id;
    a.similarity = b.similarity;
  }

  @override
  IDSimilarity operator [](int index) => _nativeData.pointer[index];

  @override
  void operator []=(int index, IDSimilarity idSimilarity) => _assign(_nativeData.pointer[index], idSimilarity);

  BufferInfo getInfo() {
    return BufferInfo(_nativeData.pointer.address, _length.pointer.address);
  }

  @override
  void free() {
    _length.free();
    _nativeData.free();
  }
}

typedef _getInfoFunction = Object Function();

void _checkErrorCode(int code, String callee, [_getInfoFunction? getInfo]) {
  if (code == Error.Ok) {
    return;
  }

  final info = getInfo?.call();

  if (!_ErrorTypes.containsKey(code)) {
    throw Error(code, callee, info);
  }

  throw _ErrorTypes[code]!(callee, info);
}

class Image extends Freeable {

  late _NativePointer<Uint32> _native;

  Image._fromNativePointer(_NativePointer<Uint32> pointer) {
    _native = pointer;
  }

  factory Image._allocate() {
    return Image._fromNativePointer(_AutoNativePointer<Uint32>.allocate(sizeOf<Uint32>()));
  }

  factory Image.fromHandle(int handle) {
    return Image._fromNativePointer(_AutoNativePointer<Uint32>.allocate(sizeOf<Uint32>())..pointer.value = handle);
  }

  factory Image.fromPointer(Pointer<Uint32> pointer) {
    return Image._fromNativePointer(_NativePointer<Uint32>(pointer));
  }

  int get handle => _native.pointer.value;
  Pointer<Uint32> get pointer => _native.pointer;

  factory Image({Image? image}) {
    return CreateEmptyImage(image: image);
  }

  @override
  void free({bool freePointer = true}) {
    FreeImage(this);
    if (freePointer) {
      _native.free();
    }
  }

  factory Image.fromFile(String fileName, {Image? image}) {
    return LoadImageFromFile(fileName, image: image);
  }

  factory Image.fromFileWithAlpha(String fileName, {Image? image}) {
    return LoadImageFromFileWithAlpha(fileName, image: image);
  }

  void saveToFile(String fileName) {
    SaveImageToFile(this, fileName);
  }

  int get width {
    return GetImageWidth(this);
  }

  int get height {
    return GetImageHeight(this);
  }

  factory Image.fromBuffer(DataBuffer buffer, int width, int height, int scanLine, ImageMode imageMode, {Image? image}) {
    return LoadImageFromBuffer(buffer, width, height, scanLine, imageMode, image: image);
  }

  int getBufferSize(ImageMode imageMode) {
    return GetImageBufferSize(this, imageMode);
  }

  DataBuffer saveToBuffer(ImageMode imageMode, {DataBuffer? buffer}) {
    return SaveImageToBuffer(this, imageMode, buffer: buffer);
  }

  factory Image.fromJpegBuffer(DataBuffer buffer, {Image? image}) {
    return LoadImageFromJpegBuffer(buffer, image: image);
  }

  factory Image.fromPngBuffer(DataBuffer buffer, {Image? image}) {
    return LoadImageFromPngBuffer(buffer, image: image);
  }

  factory Image.fromPngBufferWithAlpha(DataBuffer buffer, {Image? image}) {
    return LoadImageFromPngBufferWithAlpha(buffer, image: image);
  }

  FacePosition detectFace({FacePosition? facePosition}) {
    return DetectFace(this, facePosition: facePosition);
  }

  Face detectFace2({Face? face}) {
    return DetectFace2(this, face: face);
  }

  FacePositions detectMultipleFaces({FacePositions? faces, int maxSize = 256}) {
    return DetectMultipleFaces(this, faces: faces, maxSize: maxSize);
  }

  Faces detectMultipleFaces2({Faces? faces, int maxSize = 256}) {
    return DetectMultipleFaces2(this, faces: faces, maxSize: maxSize);
  }

  FacialFeatures detectFacialFeatures({FacialFeatures? facialFeatures}) {
    return DetectFacialFeatures(this, facialFeatures: facialFeatures);
  }

  FacialFeatures detectFacialFeaturesInRegion(FacePosition facePosition, {FacialFeatures? facialFeatures}) {
    return DetectFacialFeaturesInRegion(this, facePosition, facialFeatures: facialFeatures);
  }

  Eyes detectEyes({Eyes? eyes}) {
    return DetectEyes(this, eyes: eyes);
  }

  Eyes detectEyesInRegion(FacePosition facePosition, {Eyes? eyes}) {
    return DetectEyesInRegion(this, facePosition, eyes: eyes);
  }

  Image copy() {
    return CopyImage(this);
  }

  Image resize(double ratio) {
    return ResizeImage(this, ratio);
  }

  Image rotate90(int multiplier) {
    return RotateImage90(this, multiplier);
  }

  Image rotate(double angle) {
    return RotateImage(this, angle);
  }

  Image rotateCenter(double angle, double xCenter, double yCenter) {
    return RotateImageCenter(this, angle, xCenter, yCenter);
  }

  Image copyRect(int x1, int y1, int x2, int y2) {
    return CopyRect(this, x1, y1, x2, y2);
  }

  Image copyRectReplicateBorder(int x1, int y1, int x2, int y2) {
    return CopyRectReplicateBorder(this, x1, y1, x2, y2);
  }

  void mirror(bool useVerticalMirroringInsteadOfHorizontal) {
    MirrorImage(this, useVerticalMirroringInsteadOfHorizontal);
  }

  ExtractedFace extractFace(FacialFeatures facialFeatures, int width, int height, {Image? extractedFaceImage, FacialFeatures? resizedFeatures}) {
    return ExtractFaceImage(this, facialFeatures, width, height, extractedFaceImage: extractedFaceImage, resizedFeatures: resizedFeatures);
  }

  FaceTemplate getFaceTemplate({FaceTemplate? faceTemplate}) {
    return GetFaceTemplate(this, faceTemplate: faceTemplate);
  }

  FaceTemplate getFaceTemplate2({FaceTemplate? faceTemplate}) {
    return GetFaceTemplate2(this, faceTemplate: faceTemplate);
  }

  FaceTemplate getFaceTemplateInRegion(FacePosition facePosition, {FaceTemplate? faceTemplate}) {
    return GetFaceTemplateInRegion(this, facePosition, faceTemplate: faceTemplate);
  }

  FaceTemplate getFaceTemplateInRegion2(Face face, {FaceTemplate? faceTemplate}) {
    return GetFaceTemplateInRegion2(this, face, faceTemplate: faceTemplate);
  }

  FaceTemplate getFaceTemplateUsingFeatures(FacialFeatures facialFeatures, {FaceTemplate? faceTemplate}) {
    return GetFaceTemplateUsingFeatures(this, facialFeatures, faceTemplate: faceTemplate);
  }

  FaceTemplate getFaceTemplateUsingEyes(Eyes eyeCoords, {FaceTemplate? faceTemplate}) {
    return GetFaceTemplateUsingEyes(this, eyeCoords, faceTemplate: faceTemplate);
  }

  String detectFacialAttributeUsingFeatures(FacialFeatures facialFeatures, String attributeName, {int maxSizeInBytes = 256}) {
    return DetectFacialAttributeUsingFeatures(this, facialFeatures, attributeName, maxSizeInBytes: maxSizeInBytes);
  }

}

class Camera extends Freeable {

  late _NativePointer<Int32> _native;

  Camera._fromNativePointer(_NativePointer<Int32> pointer) {
    _native = pointer;
  }

  factory Camera._allocate() {
    return Camera._fromNativePointer(_AutoNativePointer<Int32>.allocate(sizeOf<Int32>()));
  }

  factory Camera.fromHandle(int handle) {
    return Camera._fromNativePointer(_AutoNativePointer<Int32>.allocate(sizeOf<Int32>())..pointer.value = handle);
  }

  factory Camera.fromPointer(Pointer<Int32> pointer) {
    return Camera._fromNativePointer(_NativePointer<Int32>(pointer));
  }

  int get handle => _native.pointer.value;
  Pointer<Int32> get pointer => _native.pointer;

  factory Camera.openIP(VideoCompressionType compressionType, String url, String username, String password, int timeoutSeconds, {Camera? cameraHandle}) {
    return OpenIPVideoCamera(compressionType, url, username, password, timeoutSeconds, cameraHandle: cameraHandle);
  }

  void close() {
    CloseVideoCamera(this);
  }

  Image grabFrame({Image? image}) {
    return GrabFrame(this, image: image);
  }

}

class Tracker extends Freeable {

  late _NativePointer<Uint32> _native;

  Tracker._fromNativePointer(_NativePointer<Uint32> pointer) {
    _native = pointer;
  }

  factory Tracker._allocate() {
    return Tracker._fromNativePointer(_AutoNativePointer<Uint32>.allocate(sizeOf<Uint32>()));
  }

  factory Tracker.fromHandle(int handle) {
    return Tracker._fromNativePointer(_AutoNativePointer<Uint32>.allocate(sizeOf<Uint32>())..pointer.value = handle);
  }

  factory Tracker.fromPointer(Pointer<Uint32> pointer) {
    return Tracker._fromNativePointer(_NativePointer<Uint32>(pointer));
  }

  int get handle => _native.pointer.value;
  Pointer<Uint32> get pointer => _native.pointer;

  factory Tracker({Tracker? tracker}) {
    return CreateTracker(tracker: tracker);
  }

  @override
  void free({bool freePointer = true}) {
    FreeTracker(this);
    if (freePointer) {
      _native.free();
    }
  }

  void clear() {
    ClearTracker(this);
  }

  void setParameter(String parameterName, String parameterValue) {
    SetTrackerParameter(this, parameterName, parameterValue);
  }

  void setMultipleParameters(Map<String, dynamic> parameters) {
    SetTrackerMultipleParameters(this, parameters);
  }

  String getParameter(String parameterName, {int maxSizeInBytes = 256}) {
    return GetTrackerParameter(this, parameterName, maxSizeInBytes: maxSizeInBytes);
  }

  Int64Buffer feedFrame(int cameraIdx, Image image, {Int64Buffer? ids, int maxSize = 256}) {
    return FeedFrame(this, cameraIdx, image, ids: ids, maxSize: maxSize);
  }

  Eyes getEyes(int cameraIdx, int id, {Eyes? eyes}) {
    return GetTrackerEyes(this, cameraIdx, id, eyes: eyes);
  }

  FacialFeatures getFacialFeatures(int cameraIdx, int id, {FacialFeatures? facialFeatures}) {
    return GetTrackerFacialFeatures(this, cameraIdx, id, facialFeatures: facialFeatures);
  }

  FacePosition getFacePosition(int cameraIdx, int id, {FacePosition? facePosition}) {
    return GetTrackerFacePosition(this, cameraIdx, id, facePosition: facePosition);
  }

  Face getFace(int cameraIdx, int id) {
    return GetTrackerFace(this, cameraIdx, id);
  }

  void lockID(int id) {
    LockID(this, id);
  }

  void unlockID(int id) {
    UnlockID(this, id);
  }

  void purgeID(int id) {
    PurgeID(this, id);
  }

  void setName(int id, String name) {
    SetName(this, id, name);
  }

  String getName(int id, {int maxSizeInBytes = 256}) {
    return GetName(this, id, maxSizeInBytes: maxSizeInBytes);
  }

  String getAllNames(int id, {int maxSizeInBytes = 256}) {
    return GetAllNames(this, id, maxSizeInBytes: maxSizeInBytes);
  }

  int getIDReassignment(int id) {
    return GetIDReassignment(this, id);
  }

  int getSimilarIDCount(int id) {
    return GetSimilarIDCount(this, id);
  }

  Int64Buffer getSimilarIDList(int id, {Int64Buffer? similarIDList}) {
    return GetSimilarIDList(this, id, similarIDList: similarIDList);
  }

  void saveToFile(String fileName) {
    SaveTrackerMemoryToFile(this, fileName);
  }

  factory Tracker.fromFile(String fileName, {Tracker? tracker}) {
    return LoadTrackerMemoryFromFile(fileName, tracker: tracker);
  }

  int get bufferSize {
    return GetTrackerMemoryBufferSize(this);
  }

  DataBuffer saveToBuffer({DataBuffer? buffer}) {
    return SaveTrackerMemoryToBuffer(this, buffer: buffer);
  }

  factory Tracker.fromBuffer(DataBuffer buffer, {Tracker? tracker}) {
    return LoadTrackerMemoryFromBuffer(buffer, tracker: tracker);
  }

  String getFacialAttribute(int cameraIdx, int id, String attributeName, {int maxSizeInBytes = 256}) {
    return GetTrackerFacialAttribute(this, cameraIdx, id, attributeName, maxSizeInBytes: maxSizeInBytes);
  }

  int getIDsCount() {
    return GetTrackerIDsCount(this);
  }

  Int64Buffer getAllIDs() {
    return GetTrackerAllIDs(this);
  }

  int getFaceIDsCountForID(int id) {
    return GetTrackerFaceIDsCountForID(this, id);
  }

  Int64Buffer getFaceIDsForID(int id, {Int64Buffer}) {
    return GetTrackerFaceIDsForID(this, id);
  }

  int getIDByFaceID(int faceID) {
    return GetTrackerIDByFaceID(this, faceID);
  }

  FaceTemplate getFaceTemplate(int faceID, {FaceTemplate? faceTemplate}) {
    return GetTrackerFaceTemplate(this, faceID, faceTemplate: faceTemplate);
  }

  Image getFaceImage(int faceID, {Image? image}) {
    return GetTrackerFaceImage(this, faceID, image: image);
  }

  void setFaceImage(int faceID, Image faceImage) {
    SetTrackerFaceImage(this, faceID, faceImage);
  }

  void deleteFaceImage(int faceID) {
    DeleteTrackerFaceImage(this, faceID);
  }

  TrackerCreateIDResult createID(FaceTemplate faceTemplate) {
    return TrackerCreateID(this, faceTemplate);
  }

  int addFaceTemplate(int id, FaceTemplate faceTemplate) {
    return AddTrackerFaceTemplate(this, id, faceTemplate);
  }

  void deleteFace(int faceID) {
    DeleteTrackerFace(this, faceID);
  }

  IDSimilarities matchFaces(FaceTemplate faceTemplate, double threshold, {IDSimilarities? idSimilarities, int maxCount = 1024}) {
    return TrackerMatchFaces(this, faceTemplate, threshold, idSimilarities: idSimilarities, maxCount: maxCount);
  }

}

class _ActivateLibraryWrapper {

  late int Function(Pointer<Utf8>) _func;
  late int Function(Pointer<Utf8>, Pointer<Utf8>) _setParamFunc;

  _ActivateLibraryWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Utf8>)>>('FSDK_ActivateLibrary').asFunction();
    _setParamFunc = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Utf8>, Pointer<Utf8>)>>('FSDK_SetParameter').asFunction();
  }

  void call(String licenseKey) {
    final var1 = licenseKey.toNativeUtf8();

    final environment = "environment";
    final value = "flutter";
    final env = environment.toNativeUtf8();
    final val = value.toNativeUtf8();

    try {
      _setParamFunc(env, val);
      _checkErrorCode(_func(var1), 'ActivateLibrary');
    } finally {
      malloc.free(var1);
      malloc.free(env);
      malloc.free(val);
    }
  }
}

final ActivateLibrary = _ActivateLibraryWrapper();

class _GetHardware_IDWrapper {

  late int Function(Pointer<Utf8>) _func;

  _GetHardware_IDWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Utf8>)>>('FSDK_GetHardware_ID').asFunction();
  }

  String call({int maxSize = 256}) {
    final var1 = malloc.allocate<Utf8>(maxSize);
    try {
      _checkErrorCode(_func(var1), 'GetHardware_ID');
      return var1.toDartString();
    } finally {
      malloc.free(var1);
    }
  }
}

final GetHardware_ID = _GetHardware_IDWrapper();

class _GetLicenseInfoWrapper {

  late int Function(Pointer<Utf8>) _func;

  _GetLicenseInfoWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Utf8>)>>('FSDK_GetLicenseInfo').asFunction();
  }

  String call({int maxSize = 256}) {
    final var1 = malloc.allocate<Utf8>(maxSize);
    try {
      _checkErrorCode(_func(var1), 'GetLicenseInfo');
      return var1.toDartString();
    } finally {
      malloc.free(var1);
    }
  }
}

final GetLicenseInfo = _GetLicenseInfoWrapper();

class _SetNumThreadsWrapper {

  late int Function(int) _func;

  _SetNumThreadsWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Int32)>>('FSDK_SetNumThreads').asFunction();
  }

  void call(int num) {
    _checkErrorCode(_func(num), 'SetNumThreads');
  }
}

final SetNumThreads = _SetNumThreadsWrapper();

class _GetNumThreadsWrapper {

  late int Function(Pointer<Int32>) _func;

  _GetNumThreadsWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Int32>)>>('FSDK_GetNumThreads').asFunction();
  }

  int call() {
    final var1 = malloc.allocate<Int32>(sizeOf<Int32>() * 1);
    try {
      _checkErrorCode(_func(var1), 'GetNumThreads');
      return var1.value;
    } finally {
      malloc.free(var1);
    }
  }
}

final GetNumThreads = _GetNumThreadsWrapper();

class _InitializeWrapper {

  late int Function() _func;

  _InitializeWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function()>>('FSDK_Initialize').asFunction();
  }

  void call() {
    _checkErrorCode(_func(), 'Initialize');
  }
}

final Initialize = _InitializeWrapper();

class _InitializeLibrary {

  _InitializeLibrary();

  void call() {
    Initialize();
  }
}

final InitializeLibrary = _InitializeLibrary();

class _FinalizeWrapper {

  late int Function() _func;

  _FinalizeWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function()>>('FSDK_Finalize').asFunction();
  }

  void call() {
    _checkErrorCode(_func(), 'Finalize');
  }
}

final Finalize = _FinalizeWrapper();

class _CreateEmptyImageWrapper {

  late int Function(Pointer<Uint32>) _func;

  _CreateEmptyImageWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>)>>('FSDK_CreateEmptyImage').asFunction();
  }

  Image call({Image? image}) {
    image ??= Image._allocate();
    _checkErrorCode(_func(image.pointer), 'CreateEmptyImage');
    return image;
  }
}

final CreateEmptyImage = _CreateEmptyImageWrapper();

class _FreeImageWrapper {

  late int Function(int) _func;

  _FreeImageWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32)>>('FSDK_FreeImage').asFunction();
  }

  void call(Image image) {
    _checkErrorCode(_func(image.handle), 'FreeImage');
  }
}

final FreeImage = _FreeImageWrapper();

class _LoadImageFromFileWrapper {

  late int Function(Pointer<Uint32>, Pointer<Utf8>) _func;

  _LoadImageFromFileWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>, Pointer<Utf8>)>>('FSDK_LoadImageFromFile').asFunction();
  }

  Image call(String fileName, {Image? image}) {
    image ??= Image._allocate();
    final var1 = fileName.toNativeUtf8();
    try {
      _checkErrorCode(_func(image.pointer, var1), 'LoadImageFromFile');
      return image;
    } finally {
      malloc.free(var1);
    }
  }
}

final LoadImageFromFile = _LoadImageFromFileWrapper();

class _LoadImageFromFileWithAlphaWrapper {

  late int Function(Pointer<Uint32>, Pointer<Utf8>) _func;

  _LoadImageFromFileWithAlphaWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>, Pointer<Utf8>)>>('FSDK_LoadImageFromFileWithAlpha').asFunction();
  }

  Image call(String fileName, {Image? image}) {
    image ??= Image._allocate();
    final var1 = fileName.toNativeUtf8();
    try {
      _checkErrorCode(_func(image.pointer, var1), 'LoadImageFromFileWithAlpha');
      return image;
    } finally {
      malloc.free(var1);
    }
  }
}

final LoadImageFromFileWithAlpha = _LoadImageFromFileWithAlphaWrapper();

class _SaveImageToFileWrapper {

  late int Function(int, Pointer<Utf8>) _func;

  _SaveImageToFileWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Utf8>)>>('FSDK_SaveImageToFile').asFunction();
  }

  void call(Image image, String fileName) {
    final var1 = fileName.toNativeUtf8();
    try {
      _checkErrorCode(_func(image.handle, var1), 'SaveImageToFile');
    } finally {
      malloc.free(var1);
    }
  }
}

final SaveImageToFile = _SaveImageToFileWrapper();

class _SetJpegCompressionQualityWrapper {

  late int Function(int) _func;

  _SetJpegCompressionQualityWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Int32)>>('FSDK_SetJpegCompressionQuality').asFunction();
  }

  void call(int quality) {
    _checkErrorCode(_func(quality), 'SetJpegCompressionQuality');
  }
}

final SetJpegCompressionQuality = _SetJpegCompressionQualityWrapper();

class _GetImageWidthWrapper {

  late int Function(int, Pointer<Int32>) _func;

  _GetImageWidthWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Int32>)>>('FSDK_GetImageWidth').asFunction();
  }

  int call(Image image) {
    final var1 = malloc.allocate<Int32>(sizeOf<Int32>() * 1);
    try {
      _checkErrorCode(_func(image.handle, var1), 'GetImageWidth');
      return var1.value;
    } finally {
      malloc.free(var1);
    }
  }
}

final GetImageWidth = _GetImageWidthWrapper();

class _GetImageHeightWrapper {

  late int Function(int, Pointer<Int32>) _func;

  _GetImageHeightWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Int32>)>>('FSDK_GetImageHeight').asFunction();
  }

  int call(Image image) {
    final var1 = malloc.allocate<Int32>(sizeOf<Int32>() * 1);
    try {
      _checkErrorCode(_func(image.handle, var1), 'GetImageHeight');
      return var1.value;
    } finally {
      malloc.free(var1);
    }
  }
}

final GetImageHeight = _GetImageHeightWrapper();

class _LoadImageFromBufferWrapper {

  late int Function(Pointer<Uint32>, Pointer<Uint8>, int, int, int, int) _func;

  _LoadImageFromBufferWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>, Pointer<Uint8>, Int32, Int32, Int32, Int32)>>('FSDK_LoadImageFromBuffer').asFunction();
  }

  Image call(DataBuffer buffer, int width, int height, int scanLine, ImageMode imageMode, {Image? image}) {
    image ??= Image._allocate();
    _checkErrorCode(_func(image.pointer, buffer.pointer, width, height, scanLine, imageMode.index), 'LoadImageFromBuffer');
    return image;
  }
}

final LoadImageFromBuffer = _LoadImageFromBufferWrapper();

class _GetImageBufferSizeWrapper {

  late int Function(int, Pointer<Int32>, int) _func;

  _GetImageBufferSizeWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Int32>, Int32)>>('FSDK_GetImageBufferSize').asFunction();
  }

  int call(Image image, ImageMode imageMode) {
    final var1 = malloc.allocate<Int32>(sizeOf<Int32>() * 1);
    try {
      _checkErrorCode(_func(image.handle, var1, imageMode.index), 'GetImageBufferSize');
      return var1.value;
    } finally {
      malloc.free(var1);
    }
  }
}

final GetImageBufferSize = _GetImageBufferSizeWrapper();

class _SaveImageToBufferWrapper {

  late int Function(int, Pointer<Uint8>, int) _func;

  _SaveImageToBufferWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Uint8>, Int32)>>('FSDK_SaveImageToBuffer').asFunction();
  }

  DataBuffer call(Image image, ImageMode imageMode, {DataBuffer? buffer}) {
    buffer ??= DataBuffer._allocate(image.getBufferSize(imageMode));
    _checkErrorCode(_func(image.handle, buffer.pointer, imageMode.index), 'SaveImageToBuffer');
    return buffer;
  }
}

final SaveImageToBuffer = _SaveImageToBufferWrapper();

class _LoadImageFromJpegBufferWrapper {

  late int Function(Pointer<Uint32>, Pointer<Uint8>, int) _func;

  _LoadImageFromJpegBufferWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>, Pointer<Uint8>, Int32)>>('FSDK_LoadImageFromJpegBuffer').asFunction();
  }

  Image call(DataBuffer buffer, {Image? image}) {
    image ??= Image._allocate();
    _checkErrorCode(_func(image.pointer, buffer.pointer, buffer.length), 'LoadImageFromJpegBuffer');
    return image;
  }
}

final LoadImageFromJpegBuffer = _LoadImageFromJpegBufferWrapper();

class _LoadImageFromPngBufferWrapper {

  late int Function(Pointer<Uint32>, Pointer<Uint8>, int) _func;

  _LoadImageFromPngBufferWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>, Pointer<Uint8>, Int32)>>('FSDK_LoadImageFromPngBuffer').asFunction();
  }

  Image call(DataBuffer buffer, {Image? image}) {
    image ??= Image._allocate();
    _checkErrorCode(_func(image.pointer, buffer.pointer, buffer.length), 'LoadImageFromPngBuffer');
    return image;
  }
}

final LoadImageFromPngBuffer = _LoadImageFromPngBufferWrapper();

class _LoadImageFromPngBufferWithAlphaWrapper {

  late int Function(Pointer<Uint32>, Pointer<Uint8>, int) _func;

  _LoadImageFromPngBufferWithAlphaWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>, Pointer<Uint8>, Int32)>>('FSDK_LoadImageFromPngBufferWithAlpha').asFunction();
  }

  Image call(DataBuffer buffer, {Image? image}) {
    image ??= Image._allocate();
    _checkErrorCode(_func(image.pointer, buffer.pointer, buffer.length), 'LoadImageFromPngBufferWithAlpha');
    return image;
  }
}

final LoadImageFromPngBufferWithAlpha = _LoadImageFromPngBufferWithAlphaWrapper();

class _DetectFaceWrapper {

  late int Function(int, Pointer<_FacePosition>) _func;

  _DetectFaceWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<_FacePosition>)>>('FSDK_DetectFace').asFunction();
  }

  FacePosition call(Image image, {FacePosition? facePosition}) {
    facePosition ??= FacePosition._allocate();
    _checkErrorCode(_func(image.handle, facePosition.pointer), 'DetectFace');
    return facePosition;
  }
}

final DetectFace = _DetectFaceWrapper();

class _DetectMultipleFacesWrapper {

  late int Function(int, Pointer<Int32>, Pointer<_FacePosition>, int) _func;

  _DetectMultipleFacesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Int32>, Pointer<_FacePosition>, Int32)>>('FSDK_DetectMultipleFaces').asFunction();
  }

  FacePositions call(Image image, {FacePositions? faces, int maxSize = 256}) {
    faces ??= FacePositions._allocate(maxSize);
    _checkErrorCode(_func(image.handle, faces._lengthPointer, faces.pointer, sizeOf<Int32>() * faces.capacity), 'DetectMultipleFaces');
    return faces;
  }
}

final DetectMultipleFaces = _DetectMultipleFacesWrapper();

class _DetectMultipleFaces2Wrapper {

  late int Function(int, Pointer<Int32>, Pointer<_Face>, int) _func;

  _DetectMultipleFaces2Wrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Int32>, Pointer<_Face>, Int32)>>('FSDK_DetectMultipleFaces2').asFunction();
  }

  Faces call(Image image, {Faces? faces, int maxSize = 256}) {
    faces ??= Faces._allocate(maxSize);
    _checkErrorCode(_func(image.handle, faces._lengthPointer, faces.pointer, sizeOf<Int32>() * faces.capacity), 'DetectMultipleFaces2');
    return faces;
  }
}

final DetectMultipleFaces2 = _DetectMultipleFaces2Wrapper();

class _DetectFace2Wrapper {

  late int Function(int, Pointer<_Face>) _func;

  _DetectFace2Wrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<_Face>)>>('FSDK_DetectFace2').asFunction();
  }

  Face call(Image image, {Face? face}) {
    face ??= Face._allocate();
    _checkErrorCode(_func(image.handle, face.pointer), 'DetectFace2');
    return face;
  }
}

final DetectFace2 = _DetectFace2Wrapper();

class _SetFaceDetectionParametersWrapper {

  late int Function(int, int, int) _func;

  _SetFaceDetectionParametersWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint8, Uint8, Int32)>>('FSDK_SetFaceDetectionParameters').asFunction();
  }

  void call(bool handleArbitraryRotations, bool determineFaceRotationAngle, int internalResizeWidth) {
    _checkErrorCode(_func(handleArbitraryRotations ? 1 : 0, determineFaceRotationAngle ? 1 : 0, internalResizeWidth), 'SetFaceDetectionParameters');
  }
}

final SetFaceDetectionParameters = _SetFaceDetectionParametersWrapper();

class _SetFaceDetectionThresholdWrapper {

  late int Function(int) _func;

  _SetFaceDetectionThresholdWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Int32)>>('FSDK_SetFaceDetectionThreshold').asFunction();
  }

  void call(int threshold) {
    _checkErrorCode(_func(threshold), 'SetFaceDetectionThreshold');
  }
}

final SetFaceDetectionThreshold = _SetFaceDetectionThresholdWrapper();

class _GetDetectedFaceConfidenceWrapper {

  late int Function(Pointer<Int32>) _func;

  _GetDetectedFaceConfidenceWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Int32>)>>('FSDK_GetDetectedFaceConfidence').asFunction();
  }

  int call() {
    final var1 = malloc.allocate<Int32>(sizeOf<Int32>() * 1);
    try {
      _checkErrorCode(_func(var1), 'GetDetectedFaceConfidence');
      return var1.value;
    } finally {
      malloc.free(var1);
    }
  }
}

final GetDetectedFaceConfidence = _GetDetectedFaceConfidenceWrapper();

class _DetectFacialFeaturesWrapper {

  late int Function(int, Pointer<Point>) _func;

  _DetectFacialFeaturesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Point>)>>('FSDK_DetectFacialFeatures').asFunction();
  }

  FacialFeatures call(Image image, {FacialFeatures? facialFeatures}) {
    facialFeatures ??= FacialFeatures._allocate();
    _checkErrorCode(_func(image.handle, facialFeatures.pointer), 'DetectFacialFeatures');
    return facialFeatures;
  }
}

final DetectFacialFeatures = _DetectFacialFeaturesWrapper();

class _DetectFacialFeaturesInRegionWrapper {

  late int Function(int, Pointer<_FacePosition>, Pointer<Point>) _func;

  _DetectFacialFeaturesInRegionWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<_FacePosition>, Pointer<Point>)>>('FSDK_DetectFacialFeaturesInRegion').asFunction();
  }

  FacialFeatures call(Image image, FacePosition facePosition, {FacialFeatures? facialFeatures}) {
    facialFeatures ??= FacialFeatures._allocate();
    _checkErrorCode(_func(image.handle, facePosition.pointer, facialFeatures.pointer), 'DetectFacialFeaturesInRegion');
    return facialFeatures;
  }
}

final DetectFacialFeaturesInRegion = _DetectFacialFeaturesInRegionWrapper();

class _DetectEyesWrapper {

  late int Function(int, Pointer<Point>) _func;

  _DetectEyesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Point>)>>('FSDK_DetectEyes').asFunction();
  }

  Eyes call(Image image, {Eyes? eyes}) {
    eyes ??= Eyes._allocate();
    _checkErrorCode(_func(image.handle, eyes.pointer), 'DetectEyes');
    return eyes;
  }
}

final DetectEyes = _DetectEyesWrapper();

class _DetectEyesInRegionWrapper {

  late int Function(int, Pointer<_FacePosition>, Pointer<Point>) _func;

  _DetectEyesInRegionWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<_FacePosition>, Pointer<Point>)>>('FSDK_DetectEyesInRegion').asFunction();
  }

  Eyes call(Image image, FacePosition facePosition, {Eyes? eyes}) {
    eyes ??= Eyes._allocate();
    _checkErrorCode(_func(image.handle, facePosition.pointer, eyes.pointer), 'DetectEyesInRegion');
    return eyes;
  }
}

final DetectEyesInRegion = _DetectEyesInRegionWrapper();

class _CopyImageWrapper {

  late int Function(int, int) _func;

  _CopyImageWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Uint32)>>('FSDK_CopyImage').asFunction();
  }

  Image call(Image sourceImage) {
    final var1 = CreateEmptyImage().handle;
    _checkErrorCode(_func(sourceImage.handle, var1), 'CopyImage');
    return Image.fromHandle(var1);
  }
}

final CopyImage = _CopyImageWrapper();

class _ResizeImageWrapper {

  late int Function(int, double, int) _func;

  _ResizeImageWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Double, Uint32)>>('FSDK_ResizeImage').asFunction();
  }

  Image call(Image sourceImage, double ratio) {
    final var1 = CreateEmptyImage().handle;
    _checkErrorCode(_func(sourceImage.handle, ratio, var1), 'ResizeImage');
    return Image.fromHandle(var1);
  }
}

final ResizeImage = _ResizeImageWrapper();

class _RotateImage90Wrapper {

  late int Function(int, int, int) _func;

  _RotateImage90Wrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int32, Uint32)>>('FSDK_RotateImage90').asFunction();
  }

  Image call(Image sourceImage, int multiplier) {
    final var1 = CreateEmptyImage().handle;
    _checkErrorCode(_func(sourceImage.handle, multiplier, var1), 'RotateImage90');
    return Image.fromHandle(var1);
  }
}

final RotateImage90 = _RotateImage90Wrapper();

class _RotateImageWrapper {

  late int Function(int, double, int) _func;

  _RotateImageWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Double, Uint32)>>('FSDK_RotateImage').asFunction();
  }

  Image call(Image sourceImage, double angle) {
    final var1 = CreateEmptyImage().handle;
    _checkErrorCode(_func(sourceImage.handle, angle, var1), 'RotateImage');
    return Image.fromHandle(var1);
  }
}

final RotateImage = _RotateImageWrapper();

class _RotateImageCenterWrapper {

  late int Function(int, double, double, double, int) _func;

  _RotateImageCenterWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Double, Double, Double, Uint32)>>('FSDK_RotateImageCenter').asFunction();
  }

  Image call(Image sourceImage, double angle, double xCenter, double yCenter) {
    final var1 = CreateEmptyImage().handle;
    _checkErrorCode(_func(sourceImage.handle, angle, xCenter, yCenter, var1), 'RotateImageCenter');
    return Image.fromHandle(var1);
  }
}

final RotateImageCenter = _RotateImageCenterWrapper();

class _CopyRectWrapper {

  late int Function(int, int, int, int, int, int) _func;

  _CopyRectWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int32, Int32, Int32, Int32, Uint32)>>('FSDK_CopyRect').asFunction();
  }

  Image call(Image sourceImage, int x1, int y1, int x2, int y2) {
    final var1 = CreateEmptyImage().handle;
    _checkErrorCode(_func(sourceImage.handle, x1, y1, x2, y2, var1), 'CopyRect');
    return Image.fromHandle(var1);
  }
}

final CopyRect = _CopyRectWrapper();

class _CopyRectReplicateBorderWrapper {

  late int Function(int, int, int, int, int, int) _func;

  _CopyRectReplicateBorderWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int32, Int32, Int32, Int32, Uint32)>>('FSDK_CopyRectReplicateBorder').asFunction();
  }

  Image call(Image sourceImage, int x1, int y1, int x2, int y2) {
    final var1 = CreateEmptyImage().handle;
    _checkErrorCode(_func(sourceImage.handle, x1, y1, x2, y2, var1), 'CopyRectReplicateBorder');
    return Image.fromHandle(var1);
  }
}

final CopyRectReplicateBorder = _CopyRectReplicateBorderWrapper();

class _MirrorImageWrapper {

  late int Function(int, int) _func;

  _MirrorImageWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Uint8)>>('FSDK_MirrorImage').asFunction();
  }

  void call(Image image, bool useVerticalMirroringInsteadOfHorizontal) {
    _checkErrorCode(_func(image.handle, useVerticalMirroringInsteadOfHorizontal ? 1 : 0), 'MirrorImage');
  }
}

final MirrorImage = _MirrorImageWrapper();

class _ExtractFaceImageWrapper {

  late int Function(int, Pointer<Point>, int, int, Pointer<Uint32>, Pointer<Point>) _func;

  _ExtractFaceImageWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Point>, Int32, Int32, Pointer<Uint32>, Pointer<Point>)>>('FSDK_ExtractFaceImage').asFunction();
  }

  ExtractedFace call(Image image, FacialFeatures facialFeatures, int width, int height, {Image? extractedFaceImage, FacialFeatures? resizedFeatures}) {
    extractedFaceImage ??= Image._allocate();
    resizedFeatures ??= FacialFeatures.allocate();
    _checkErrorCode(_func(image.handle, facialFeatures.pointer, width, height, extractedFaceImage.pointer, resizedFeatures.pointer), 'ExtractFaceImage');
    return ExtractedFace(extractedFaceImage, resizedFeatures);
  }
}

final ExtractFaceImage = _ExtractFaceImageWrapper();

class _GetFaceTemplateWrapper {

  late int Function(int, Pointer<Uint8>) _func;

  _GetFaceTemplateWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Uint8>)>>('FSDK_GetFaceTemplate').asFunction();
  }

  FaceTemplate call(Image image, {FaceTemplate? faceTemplate}) {
    faceTemplate ??= FaceTemplate._allocate();
    _checkErrorCode(_func(image.handle, faceTemplate.pointer), 'GetFaceTemplate');
    return faceTemplate;
  }
}

final GetFaceTemplate = _GetFaceTemplateWrapper();

class _GetFaceTemplate2Wrapper {

  late int Function(int, Pointer<Uint8>) _func;

  _GetFaceTemplate2Wrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Uint8>)>>('FSDK_GetFaceTemplate2').asFunction();
  }

  FaceTemplate call(Image image, {FaceTemplate? faceTemplate}) {
    faceTemplate ??= FaceTemplate._allocate();
    _checkErrorCode(_func(image.handle, faceTemplate.pointer), 'GetFaceTemplate2');
    return faceTemplate;
  }
}

final GetFaceTemplate2 = _GetFaceTemplate2Wrapper();

class _GetFaceTemplateInRegionWrapper {

  late int Function(int, Pointer<_FacePosition>, Pointer<Uint8>) _func;

  _GetFaceTemplateInRegionWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<_FacePosition>, Pointer<Uint8>)>>('FSDK_GetFaceTemplateInRegion').asFunction();
  }

  FaceTemplate call(Image image, FacePosition facePosition, {FaceTemplate? faceTemplate}) {
    faceTemplate ??= FaceTemplate._allocate();
    _checkErrorCode(_func(image.handle, facePosition.pointer, faceTemplate.pointer), 'GetFaceTemplateInRegion');
    return faceTemplate;
  }
}

final GetFaceTemplateInRegion = _GetFaceTemplateInRegionWrapper();

class _GetFaceTemplateInRegion2Wrapper {

  late int Function(int, Pointer<_Face>, Pointer<Uint8>) _func;

  _GetFaceTemplateInRegion2Wrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<_Face>, Pointer<Uint8>)>>('FSDK_GetFaceTemplateInRegion2').asFunction();
  }

  FaceTemplate call(Image image, Face face, {FaceTemplate? faceTemplate}) {
    faceTemplate ??= FaceTemplate._allocate();
    _checkErrorCode(_func(image.handle, face.pointer, faceTemplate.pointer), 'GetFaceTemplateInRegion');
    return faceTemplate;
  }
}

final GetFaceTemplateInRegion2 = _GetFaceTemplateInRegion2Wrapper();

class _GetFaceTemplateUsingFeaturesWrapper {

  late int Function(int, Pointer<Point>, Pointer<Uint8>) _func;

  _GetFaceTemplateUsingFeaturesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Point>, Pointer<Uint8>)>>('FSDK_GetFaceTemplateUsingFeatures').asFunction();
  }

  FaceTemplate call(Image image, FacialFeatures facialFeatures, {FaceTemplate? faceTemplate}) {
    faceTemplate ??= FaceTemplate._allocate();
    _checkErrorCode(_func(image.handle, facialFeatures.pointer, faceTemplate.pointer), 'GetFaceTemplateUsingFeatures');
    return faceTemplate;
  }
}

final GetFaceTemplateUsingFeatures = _GetFaceTemplateUsingFeaturesWrapper();

class _GetFaceTemplateUsingEyesWrapper {

  late int Function(int, Pointer<Point>, Pointer<Uint8>) _func;

  _GetFaceTemplateUsingEyesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Point>, Pointer<Uint8>)>>('FSDK_GetFaceTemplateUsingEyes').asFunction();
  }

  FaceTemplate call(Image image, Eyes eyeCoords, {FaceTemplate? faceTemplate}) {
    faceTemplate ??= FaceTemplate._allocate();
    _checkErrorCode(_func(image.handle, eyeCoords.pointer, faceTemplate.pointer), 'GetFaceTemplateUsingEyes');
    return faceTemplate;
  }
}

final GetFaceTemplateUsingEyes = _GetFaceTemplateUsingEyesWrapper();

class _MatchFacesWrapper {

  late int Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Float>) _func;

  _MatchFacesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Float>)>>('FSDK_MatchFaces').asFunction();
  }

  double call(FaceTemplate faceTemplate1, FaceTemplate faceTemplate2) {
    final var1 = malloc.allocate<Float>(sizeOf<Float>() * 1);
    try {
      _checkErrorCode(_func(faceTemplate1.pointer, faceTemplate2.pointer, var1), 'MatchFaces');
      return var1.value;
    } finally {
      malloc.free(var1);
    }
  }
}

final MatchFaces = _MatchFacesWrapper();

class _GetMatchingThresholdAtFARWrapper {

  late int Function(double, Pointer<Float>) _func;

  _GetMatchingThresholdAtFARWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Float, Pointer<Float>)>>('FSDK_GetMatchingThresholdAtFAR').asFunction();
  }

  double call(double fARValue) {
    final var1 = malloc.allocate<Float>(sizeOf<Float>() * 1);
    try {
      _checkErrorCode(_func(fARValue, var1), 'GetMatchingThresholdAtFAR');
      return var1.value;
    } finally {
      malloc.free(var1);
    }
  }
}

final GetMatchingThresholdAtFAR = _GetMatchingThresholdAtFARWrapper();

class _GetMatchingThresholdAtFRRWrapper {

  late int Function(double, Pointer<Float>) _func;

  _GetMatchingThresholdAtFRRWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Float, Pointer<Float>)>>('FSDK_GetMatchingThresholdAtFRR').asFunction();
  }

  double call(double fRRValue) {
    final var1 = malloc.allocate<Float>(sizeOf<Float>() * 1);
    try {
      _checkErrorCode(_func(fRRValue, var1), 'GetMatchingThresholdAtFRR');
      return var1.value;
    } finally {
      malloc.free(var1);
    }
  }
}

final GetMatchingThresholdAtFRR = _GetMatchingThresholdAtFRRWrapper();

class _CreateTrackerWrapper {

  late int Function(Pointer<Uint32>) _func;

  _CreateTrackerWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>)>>('FSDK_CreateTracker').asFunction();
  }

  Tracker call({Tracker? tracker}) {
    tracker ??= Tracker._allocate();
    _checkErrorCode(_func(tracker.pointer), 'CreateTracker');
    return tracker;
  }
}

final CreateTracker = _CreateTrackerWrapper();

class _FreeTrackerWrapper {

  late int Function(int) _func;

  _FreeTrackerWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32)>>('FSDK_FreeTracker').asFunction();
  }

  void call(Tracker tracker) {
    _checkErrorCode(_func(tracker.handle), 'FreeTracker');
  }
}

final FreeTracker = _FreeTrackerWrapper();

class _ClearTrackerWrapper {

  late int Function(int) _func;

  _ClearTrackerWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32)>>('FSDK_ClearTracker').asFunction();
  }

  void call(Tracker tracker) {
    _checkErrorCode(_func(tracker.handle), 'ClearTracker');
  }
}

final ClearTracker = _ClearTrackerWrapper();

class _SetTrackerParameterWrapper {

  late int Function(int, Pointer<Utf8>, Pointer<Utf8>) _func;

  _SetTrackerParameterWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Utf8>, Pointer<Utf8>)>>('FSDK_SetTrackerParameter').asFunction();
  }

  void call(Tracker tracker, String parameterName, String parameterValue) {
    final var1 = parameterName.toNativeUtf8();
    final var2 = parameterValue.toNativeUtf8();
    try {
      _checkErrorCode(_func(tracker.handle, var1, var2), 'SetTrackerParameter');
    } finally {
      malloc.free(var2);
      malloc.free(var1);
    }
  }
}

final SetTrackerParameter = _SetTrackerParameterWrapper();

class _SetTrackerMultipleParametersWrapper {

  late int Function(int, Pointer<Utf8>, Pointer<Int32>) _func;

  _SetTrackerMultipleParametersWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Utf8>, Pointer<Int32>)>>('FSDK_SetTrackerMultipleParameters').asFunction();
  }

  void call(Tracker tracker, Map<String, dynamic> parameters) {
    final var1 = parameters.entries.map((entry) => '${entry.key}=${entry.value}').join(';').toNativeUtf8();
    final var2 = malloc.allocate<Int32>(sizeOf<Int32>());
    try {
      _checkErrorCode(_func(tracker.handle, var1, var2), 'SetTrackerMultipleParameters', () => var2.value);
    } finally {
      malloc.free(var2);
      malloc.free(var1);
    }
  }
}

final SetTrackerMultipleParameters = _SetTrackerMultipleParametersWrapper();

class _GetTrackerParameterWrapper {

  late int Function(int, Pointer<Utf8>, Pointer<Utf8>, int) _func;

  _GetTrackerParameterWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Utf8>, Pointer<Utf8>, Int32)>>('FSDK_GetTrackerParameter').asFunction();
  }

  String call(Tracker tracker, String parameterName, {int maxSizeInBytes = 256}) {
    final var1 = parameterName.toNativeUtf8();
    final var2 = malloc.allocate<Utf8>(maxSizeInBytes);
    try {
      _checkErrorCode(_func(tracker.handle, var1, var2, maxSizeInBytes), 'GetTrackerParameter');
      return var2.toDartString();
    } finally {
      malloc.free(var2);
      malloc.free(var1);
    }
  }
}

final GetTrackerParameter = _GetTrackerParameterWrapper();

class _FeedFrameWrapper {

  late int Function(int, int, int, Pointer<Int64>, Pointer<Int64>, int) _func;

  _FeedFrameWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Uint32, Pointer<Int64>, Pointer<Int64>, Int64)>>('FSDK_FeedFrame').asFunction();
  }

  Int64Buffer call(Tracker tracker, int cameraIdx, Image image, {Int64Buffer? ids, int maxSize = 256}) {
    ids ??= Int64Buffer._allocate(maxSize);
    _checkErrorCode(_func(tracker.handle, cameraIdx, image.handle, ids._lengthPointer, ids.pointer, sizeOf<Int64>() * ids.capacity), 'FeedFrame');
    return ids;
  }
}

final FeedFrame = _FeedFrameWrapper();

class _GetTrackerEyesWrapper {

  late int Function(int, int, int, Pointer<Point>) _func;

  _GetTrackerEyesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Int64, Pointer<Point>)>>('FSDK_GetTrackerEyes').asFunction();
  }

  Eyes call(Tracker tracker, int cameraIdx, int id, {Eyes? eyes}) {
    eyes ??= Eyes._allocate();
    _checkErrorCode(_func(tracker.handle, cameraIdx, id, eyes.pointer), 'GetTrackerEyes');
    return eyes;
  }
}

final GetTrackerEyes = _GetTrackerEyesWrapper();

class _GetTrackerFacialFeaturesWrapper {

  late int Function(int, int, int, Pointer<Point>) _func;

  _GetTrackerFacialFeaturesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Int64, Pointer<Point>)>>('FSDK_GetTrackerFacialFeatures').asFunction();
  }

  FacialFeatures call(Tracker tracker, int cameraIdx, int id, {FacialFeatures? facialFeatures}) {
    facialFeatures ??= FacialFeatures._allocate();
    _checkErrorCode(_func(tracker.handle, cameraIdx, id, facialFeatures.pointer), 'GetTrackerFacialFeatures');
    return facialFeatures;
  }
}

final GetTrackerFacialFeatures = _GetTrackerFacialFeaturesWrapper();

class _GetTrackerFacePositionWrapper {

  late int Function(int, int, int, Pointer<_FacePosition>) _func;

  _GetTrackerFacePositionWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Int64, Pointer<_FacePosition>)>>('FSDK_GetTrackerFacePosition').asFunction();
  }

  FacePosition call(Tracker tracker, int cameraIdx, int id, {FacePosition? facePosition}) {
    facePosition ??= FacePosition._allocate();
    _checkErrorCode(_func(tracker.handle, cameraIdx, id, facePosition.pointer), 'GetTrackerFacePosition');
    return facePosition;
  }
}

final GetTrackerFacePosition = _GetTrackerFacePositionWrapper();

class _GetTrackerFaceWrapper {

  late int Function(int, int, int, Pointer<_Face>) _func;

  _GetTrackerFaceWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Int64, Pointer<_Face>)>>('FSDK_GetTrackerFace').asFunction();
  }

  Face call(Tracker tracker, int cameraIdx, int id, {Face? face}) {
    face ??= Face._allocate();
    _checkErrorCode(_func(tracker.handle, cameraIdx, id, face.pointer), 'GetTrackerFace');
    return face;
  }
}

final GetTrackerFace = _GetTrackerFaceWrapper();

class _LockIDWrapper {

  late int Function(int, int) _func;

  _LockIDWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64)>>('FSDK_LockID').asFunction();
  }

  void call(Tracker tracker, int id) {
    _checkErrorCode(_func(tracker.handle, id), 'LockID');
  }
}

final LockID = _LockIDWrapper();

class _UnlockIDWrapper {

  late int Function(int, int) _func;

  _UnlockIDWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64)>>('FSDK_UnlockID').asFunction();
  }

  void call(Tracker tracker, int id) {
    _checkErrorCode(_func(tracker.handle, id), 'UnlockID');
  }
}

final UnlockID = _UnlockIDWrapper();

class _PurgeIDWrapper {

  late int Function(int, int) _func;

  _PurgeIDWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64)>>('FSDK_PurgeID').asFunction();
  }

  void call(Tracker tracker, int id) {
    _checkErrorCode(_func(tracker.handle, id), 'PurgeID');
  }
}

final PurgeID = _PurgeIDWrapper();

class _SetNameWrapper {

  late int Function(int, int, Pointer<Utf8>) _func;

  _SetNameWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Pointer<Utf8>)>>('FSDK_SetName').asFunction();
  }

  void call(Tracker tracker, int id, String name) {
    final var1 = name.toNativeUtf8();
    try {
      _checkErrorCode(_func(tracker.handle, id, var1), 'SetName');
    } finally {
      malloc.free(var1);
    }
  }
}

final SetName = _SetNameWrapper();

class _GetNameWrapper {

  late int Function(int, int, Pointer<Utf8>, int) _func;

  _GetNameWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Pointer<Utf8>, Int64)>>('FSDK_GetName').asFunction();
  }

  String call(Tracker tracker, int id, {int maxSizeInBytes = 256}) {
    final var1 = malloc.allocate<Utf8>(maxSizeInBytes);
    try {
      _checkErrorCode(_func(tracker.handle, id, var1, maxSizeInBytes), 'GetName');
      return var1.toDartString();
    } finally {
      malloc.free(var1);
    }
  }
}

final GetName = _GetNameWrapper();

class _GetAllNamesWrapper {

  late int Function(int, int, Pointer<Utf8>, int) _func;

  _GetAllNamesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Pointer<Utf8>, Int64)>>('FSDK_GetAllNames').asFunction();
  }

  String call(Tracker tracker, int id, {int maxSizeInBytes = 256}) {
    final var1 = malloc.allocate<Utf8>(maxSizeInBytes);
    try {
      _checkErrorCode(_func(tracker.handle, id, var1, maxSizeInBytes), 'GetAllNames');
      return var1.toDartString();
    } finally {
      malloc.free(var1);
    }
  }
}

final GetAllNames = _GetAllNamesWrapper();

class _GetIDReassignmentWrapper {

  late int Function(int, int, Pointer<Int64>) _func;

  _GetIDReassignmentWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Pointer<Int64>)>>('FSDK_GetIDReassignment').asFunction();
  }

  int call(Tracker tracker, int id) {
    final var1 = malloc.allocate<Int64>(sizeOf<Int64>() * 1);
    try {
      _checkErrorCode(_func(tracker.handle, id, var1), 'GetIDReassignment');
      return var1.value;
    } finally {
      malloc.free(var1);
    }
  }
}

final GetIDReassignment = _GetIDReassignmentWrapper();

class _GetSimilarIDCountWrapper {

  late int Function(int, int, Pointer<Int64>) _func;

  _GetSimilarIDCountWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Pointer<Int64>)>>('FSDK_GetSimilarIDCount').asFunction();
  }

  int call(Tracker tracker, int id) {
    final var1 = malloc.allocate<Int64>(sizeOf<Int64>() * 1);
    try {
      _checkErrorCode(_func(tracker.handle, id, var1), 'GetSimilarIDCount');
      return var1.value;
    } finally {
      malloc.free(var1);
    }
  }
}

final GetSimilarIDCount = _GetSimilarIDCountWrapper();

class _GetSimilarIDListWrapper {

  late int Function(int, int, Pointer<Int64>, int) _func;

  _GetSimilarIDListWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Pointer<Int64>, Int64)>>('FSDK_GetSimilarIDList').asFunction();
  }

  Int64Buffer call(Tracker tracker, int id, {Int64Buffer? similarIDList}) {
    similarIDList ??= Int64Buffer._allocate(GetSimilarIDCount(tracker, id));
    _checkErrorCode(_func(tracker.handle, id, similarIDList.pointer, sizeOf<Int64>() * similarIDList.capacity), 'GetSimilarIDList');
    return similarIDList;
  }
}

final GetSimilarIDList = _GetSimilarIDListWrapper();

class _SaveTrackerMemoryToFileWrapper {

  late int Function(int, Pointer<Utf8>) _func;

  _SaveTrackerMemoryToFileWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Utf8>)>>('FSDK_SaveTrackerMemoryToFile').asFunction();
  }

  void call(Tracker tracker, String fileName) {
    final var1 = fileName.toNativeUtf8();
    try {
      _checkErrorCode(_func(tracker.handle, var1), 'SaveTrackerMemoryToFile');
    } finally {
      malloc.free(var1);
    }
  }
}

final SaveTrackerMemoryToFile = _SaveTrackerMemoryToFileWrapper();

class _LoadTrackerMemoryFromFileWrapper {

  late int Function(Pointer<Uint32>, Pointer<Utf8>) _func;

  _LoadTrackerMemoryFromFileWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>, Pointer<Utf8>)>>('FSDK_LoadTrackerMemoryFromFile').asFunction();
  }

  Tracker call(String fileName, {Tracker? tracker}) {
    tracker ??= Tracker._allocate();
    final var1 = fileName.toNativeUtf8();
    try {
      _checkErrorCode(_func(tracker.pointer, var1), 'LoadTrackerMemoryFromFile');
      return tracker;
    } finally {
      malloc.free(var1);
    }
  }
}

final LoadTrackerMemoryFromFile = _LoadTrackerMemoryFromFileWrapper();

class _GetTrackerMemoryBufferSizeWrapper {

  late int Function(int, Pointer<Int64>) _func;

  _GetTrackerMemoryBufferSizeWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Int64>)>>('FSDK_GetTrackerMemoryBufferSize').asFunction();
  }

  int call(Tracker tracker) {
    final var1 = malloc.allocate<Int64>(sizeOf<Int64>() * 1);
    try {
      _checkErrorCode(_func(tracker.handle, var1), 'GetTrackerMemoryBufferSize');
      return var1.value;
    } finally {
      malloc.free(var1);
    }
  }
}

final GetTrackerMemoryBufferSize = _GetTrackerMemoryBufferSizeWrapper();

class _SaveTrackerMemoryToBufferWrapper {

  late int Function(int, Pointer<Uint8>) _func;

  _SaveTrackerMemoryToBufferWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Uint8>)>>('FSDK_SaveTrackerMemoryToBuffer').asFunction();
  }

  DataBuffer call(Tracker tracker, {DataBuffer? buffer}) {
    buffer ??= DataBuffer._allocate(tracker.bufferSize);
    _checkErrorCode(_func(tracker.handle, buffer.pointer), 'SaveTrackerMemoryToBuffer');
    return buffer;
  }
}

final SaveTrackerMemoryToBuffer = _SaveTrackerMemoryToBufferWrapper();

class _LoadTrackerMemoryFromBufferWrapper {

  late int Function(Pointer<Uint32>, Pointer<Uint8>) _func;

  _LoadTrackerMemoryFromBufferWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>, Pointer<Uint8>)>>('FSDK_LoadTrackerMemoryFromBuffer').asFunction();
  }

  Tracker call(DataBuffer buffer, {Tracker? tracker}) {
    tracker ??= Tracker._allocate();
    _checkErrorCode(_func(tracker.pointer, buffer.pointer), 'LoadTrackerMemoryFromBuffer');
    return tracker;
  }
}

final LoadTrackerMemoryFromBuffer = _LoadTrackerMemoryFromBufferWrapper();

class _GetTrackerFacialAttributeWrapper {

  late int Function(int, int, int, Pointer<Utf8>, Pointer<Utf8>, int) _func;

  _GetTrackerFacialAttributeWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Int64, Pointer<Utf8>, Pointer<Utf8>, Int64)>>('FSDK_GetTrackerFacialAttribute').asFunction();
  }

  String call(Tracker tracker, int cameraIdx, int id, String attributeName, {int maxSizeInBytes = 256}) {
    final var1 = attributeName.toNativeUtf8();
    final var2 = malloc.allocate<Utf8>(maxSizeInBytes);
    try {
      _checkErrorCode(_func(tracker.handle, cameraIdx, id, var1, var2, maxSizeInBytes), 'GetTrackerFacialAttribute');
      return var2.toDartString();
    } finally {
      malloc.free(var2);
      malloc.free(var1);
    }
  }
}

final GetTrackerFacialAttribute = _GetTrackerFacialAttributeWrapper();

class _GetTrackerIDsCountWrapper {
  
  late int Function(int, Pointer<Int64>) _func;

  _GetTrackerIDsCountWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Int64>)>>('FSDK_GetTrackerIDsCount').asFunction();
  }

  int call(Tracker tracker) {
    final countPtr = malloc<Int64>();
    try {
      _checkErrorCode(_func(tracker.handle, countPtr), 'GetTrackerIDsCount');
      return countPtr.value;
    } finally {
      malloc.free(countPtr);
    }
  }
}

final GetTrackerIDsCount = _GetTrackerIDsCountWrapper();

class _GetTrackerAllIDsWrapper {
  late int Function(int, Pointer<Int64>, int) _func;

  _GetTrackerAllIDsWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Int64>, Int64)>>('FSDK_GetTrackerAllIDs').asFunction();
  }

  Int64Buffer call(Tracker tracker, {Int64Buffer? ids}) {
    ids ??= Int64Buffer._allocate(GetTrackerIDsCount(tracker));
    _checkErrorCode(_func(tracker.handle, ids.pointer, sizeOf<Int64>() * ids.capacity), 'GetTrackerAllIDs');
    return ids;
  }
}

final GetTrackerAllIDs = _GetTrackerAllIDsWrapper();

class _GetTrackerFaceIDsCountForIDWrapper {
  late int Function(int, int, Pointer<Int64>) _func;

  _GetTrackerFaceIDsCountForIDWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Pointer<Int64>)>>('FSDK_GetTrackerFaceIDsCountForID').asFunction();
  }

  int call(Tracker tracker, int id) {
    final countPtr = malloc<Int64>();
    try {
      _checkErrorCode(_func(tracker.handle, id, countPtr), 'GetTrackerFaceIDsCountForID');
      return countPtr.value;
    } finally {
      malloc.free(countPtr);
    }
  }
}

final GetTrackerFaceIDsCountForID = _GetTrackerFaceIDsCountForIDWrapper();

class _GetTrackerFaceIDsForIDWrapper {
  late int Function(int, int, Pointer<Int64>, int) _func;

  _GetTrackerFaceIDsForIDWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Pointer<Int64>, Int64)>>('FSDK_GetTrackerFaceIDsForID').asFunction();
  }

  Int64Buffer call(Tracker tracker, int id, {Int64Buffer? faceIDs}) {
    faceIDs ??= Int64Buffer.allocate(GetTrackerFaceIDsCountForID(tracker, id));
    _checkErrorCode(_func(tracker.handle, id, faceIDs.pointer, sizeOf<Int64>() * faceIDs.capacity), 'GetTrackerFaceIDsForID');
    return faceIDs;
  }
}

final GetTrackerFaceIDsForID = _GetTrackerFaceIDsForIDWrapper();

class _GetTrackerIDByFaceIDWrapper {
  late int Function(int, int, Pointer<Int64>) _func;

  _GetTrackerIDByFaceIDWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Pointer<Int64>)>>('FSDK_GetTrackerIDByFaceID').asFunction();
  }

  int call(Tracker tracker, int faceID) {
    final idPtr = malloc<Int64>();
    try {
      _checkErrorCode(_func(tracker.handle, faceID, idPtr), 'GetTrackerIDByFaceID');
      return idPtr.value;
    } finally {
      malloc.free(idPtr);
    }
  }
}

final GetTrackerIDByFaceID = _GetTrackerIDByFaceIDWrapper();

class _GetTrackerFaceTemplateWrapper {
  late int Function(int, int, Pointer<Uint8>) _func;

  _GetTrackerFaceTemplateWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Pointer<Uint8>)>>('FSDK_GetTrackerFaceTemplate').asFunction();
  }

  FaceTemplate call(Tracker tracker, int faceID, {FaceTemplate? faceTemplate}) {
    faceTemplate ??= FaceTemplate.allocate();
    _checkErrorCode(_func(tracker.handle, faceID, faceTemplate.pointer), 'GetTrackerFaceTemplate');
    return faceTemplate;
  }
}

final GetTrackerFaceTemplate = _GetTrackerFaceTemplateWrapper();

class _GetTrackerFaceImageWrapper {
  late int Function(int, int, Pointer<Uint32>) _func;

  _GetTrackerFaceImageWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Pointer<Uint32>)>>('FSDK_GetTrackerFaceImage').asFunction();
  }

  Image call(Tracker tracker, int faceID, {Image? image}) {
    image ??= Image._allocate();
    _checkErrorCode(_func(tracker.handle, faceID, image.pointer), 'GetTrackerFaceImage');
    return image;
  }
}

final GetTrackerFaceImage = _GetTrackerFaceImageWrapper();

class _SetTrackerFaceImageWrapper {
  late int Function(int, int, int) _func;

  _SetTrackerFaceImageWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Uint32)>>('FSDK_SetTrackerFaceImage').asFunction();
  }

  void call(Tracker tracker, int faceID, Image faceImage) {
    _checkErrorCode(_func(tracker.handle, faceID, faceImage.handle), 'SetTrackerFaceImage');
  }
}

final SetTrackerFaceImage = _SetTrackerFaceImageWrapper();

class _DeleteTrackerFaceImageWrapper {
  late int Function(int, int) _func;

  _DeleteTrackerFaceImageWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64)>>('FSDK_DeleteTrackerFaceImage').asFunction();
  }

  void call(Tracker tracker, int faceID) {
    _checkErrorCode(_func(tracker.handle, faceID), 'DeleteTrackerFaceImage');
  }
}

final DeleteTrackerFaceImage = _DeleteTrackerFaceImageWrapper();

class TrackerCreateIDResult {
  final int id;
  final int faceID;

  TrackerCreateIDResult(this.id, this.faceID);
}

class _TrackerCreateIDWrapper {
  late int Function(int, Pointer<Uint8>, Pointer<Int64>, Pointer<Int64>) _func;

  _TrackerCreateIDWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Uint8>, Pointer<Int64>, Pointer<Int64>)>>('FSDK_TrackerCreateID').asFunction();
  }

  TrackerCreateIDResult call(Tracker tracker, FaceTemplate faceTemplate) {
    final idPtr = malloc<Int64>();
    final faceIDPtr = malloc<Int64>();
    try {
      _checkErrorCode(_func(tracker.handle, faceTemplate.pointer, idPtr, faceIDPtr), 'TrackerCreateID');
      return TrackerCreateIDResult(idPtr.value, faceIDPtr.value);
    } finally {
      malloc.free(idPtr);
      malloc.free(faceIDPtr);
    }
  }
}

final TrackerCreateID = _TrackerCreateIDWrapper();

class _AddTrackerFaceTemplateWrapper {
  late int Function(int, int, Pointer<Uint8>, Pointer<Int64>) _func;

  _AddTrackerFaceTemplateWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Pointer<Uint8>, Pointer<Int64>)>>('FSDK_AddTrackerFaceTemplate').asFunction();
  }

  int call(Tracker tracker, int id, FaceTemplate faceTemplate) {
    final faceIDPtr = malloc<Int64>();
    try {
      _checkErrorCode(_func(tracker.handle, id, faceTemplate.pointer, faceIDPtr), 'AddTrackerFaceTemplate');
      return faceIDPtr.value;
    } finally {
      malloc.free(faceIDPtr);
    }
  }
}

final AddTrackerFaceTemplate = _AddTrackerFaceTemplateWrapper();

class _DeleteTrackerFaceWrapper {
  late int Function(int, int) _func;

  _DeleteTrackerFaceWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64)>>('FSDK_DeleteTrackerFace').asFunction();
  }

  void call(Tracker tracker, int faceID) {
    _checkErrorCode(_func(tracker.handle, faceID), 'DeleteTrackerFace');
  }
}

final DeleteTrackerFace = _DeleteTrackerFaceWrapper();

class IDSimilarityResult {
  final int id;
  final double similarity;

  IDSimilarityResult(this.id, this.similarity);
}

class _TrackerMatchFacesWrapper {

  late int Function(int, Pointer<Uint8>, double, Pointer<IDSimilarity>, Pointer<Int64>, int) _func;

  _TrackerMatchFacesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Uint8>, Float, Pointer<IDSimilarity>, Pointer<Int64>, Int64)>>('FSDK_TrackerMatchFaces').asFunction();
  }

  IDSimilarities call(Tracker tracker, FaceTemplate faceTemplate, double threshold, {IDSimilarities? idSimilarities, int maxCount = 1024}) {
    idSimilarities ??= IDSimilarities.allocate(maxCount);
    _checkErrorCode(_func(tracker.handle, faceTemplate.pointer, threshold, idSimilarities.pointer, idSimilarities._lengthPointer, idSimilarities.capacity), 'TrackerMatchFaces');
    return idSimilarities;
  }
}

final TrackerMatchFaces = _TrackerMatchFacesWrapper();

class _DetectFacialAttributeUsingFeaturesWrapper {

  late int Function(int, Pointer<Point>, Pointer<Utf8>, Pointer<Utf8>, int) _func;

  _DetectFacialAttributeUsingFeaturesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Point>, Pointer<Utf8>, Pointer<Utf8>, Int64)>>('FSDK_DetectFacialAttributeUsingFeatures').asFunction();
  }

  String call(Image image, FacialFeatures facialFeatures, String attributeName, {int maxSizeInBytes = 256}) {
    final var1 = attributeName.toNativeUtf8();
    final var2 = malloc.allocate<Utf8>(maxSizeInBytes);
    try {
      _checkErrorCode(_func(image.handle, facialFeatures.pointer, var1, var2, maxSizeInBytes), 'DetectFacialAttributeUsingFeatures');
      return var2.toDartString();
    } finally {
      malloc.free(var2);
      malloc.free(var1);
    }
  }
}

final DetectFacialAttributeUsingFeatures = _DetectFacialAttributeUsingFeaturesWrapper();

class _GetValueConfidenceWrapper {

  late int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Float>) _func;

  _GetValueConfidenceWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Float>)>>('FSDK_GetValueConfidence').asFunction();
  }

  double call(String attributeValues, String value) {
    final var1 = attributeValues.toNativeUtf8();
    final var2 = value.toNativeUtf8();
    final var3 = malloc.allocate<Float>(sizeOf<Float>() * 1);
    try {
      _checkErrorCode(_func(var1, var2, var3), 'GetValueConfidence');
      return var3.value;
    } finally {
      malloc.free(var3);
      malloc.free(var2);
      malloc.free(var1);
    }
  }
}

final GetValueConfidence = _GetValueConfidenceWrapper();

class _SetHTTPProxyWrapper {

  late int Function(Pointer<Utf8>, int, Pointer<Utf8>, Pointer<Utf8>) _func;

  _SetHTTPProxyWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Utf8>, Int16, Pointer<Utf8>, Pointer<Utf8>)>>('FSDK_SetHTTPProxy').asFunction();
  }

  void call(String serverNameOrIPAddress, int port, String userName, String password) {
    final var1 = serverNameOrIPAddress.toNativeUtf8();
    final var2 = userName.toNativeUtf8();
    final var3 = password.toNativeUtf8();
    try {
      _checkErrorCode(_func(var1, port, var2, var3), 'SetHTTPProxy');
    } finally {
      malloc.free(var3);
      malloc.free(var2);
      malloc.free(var1);
    }
  }
}

final SetHTTPProxy = _SetHTTPProxyWrapper();

class _OpenIPVideoCameraWrapper {

  late int Function(int, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, int, Pointer<Int32>) _func;

  _OpenIPVideoCameraWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Int32, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Int32, Pointer<Int32>)>>('FSDK_OpenIPVideoCamera').asFunction();
  }

  Camera call(VideoCompressionType compressionType, String url, String username, String password, int timeoutSeconds, {Camera? cameraHandle}) {
    final var1 = url.toNativeUtf8();
    final var2 = username.toNativeUtf8();
    final var3 = password.toNativeUtf8();
    cameraHandle ??= Camera._allocate();
    try {
      _checkErrorCode(_func(compressionType.index, var1, var2, var3, timeoutSeconds, cameraHandle.pointer), 'OpenIPVideoCamera');
      return cameraHandle;
    } finally {
      malloc.free(var3);
      malloc.free(var2);
      malloc.free(var1);
    }
  }
}

final OpenIPVideoCamera = _OpenIPVideoCameraWrapper();

class _CloseVideoCameraWrapper {

  late int Function(int) _func;

  _CloseVideoCameraWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Int32)>>('FSDK_CloseVideoCamera').asFunction();
  }

  void call(Camera cameraHandle) {
    _checkErrorCode(_func(cameraHandle.handle), 'CloseVideoCamera');
  }
}

final CloseVideoCamera = _CloseVideoCameraWrapper();

class _GrabFrameWrapper {

  late int Function(int, Pointer<Uint32>) _func;

  _GrabFrameWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Int32, Pointer<Uint32>)>>('FSDK_GrabFrame').asFunction();
  }

  Image call(Camera cameraHandle, {Image? image}) {
    image ??= Image._allocate();
    _checkErrorCode(_func(cameraHandle.handle, image.pointer), 'GrabFrame');
    return image;
  }
}

final GrabFrame = _GrabFrameWrapper();

class _InitializeCapturingWrapper {

  late int Function() _func;

  _InitializeCapturingWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function()>>('FSDK_InitializeCapturing').asFunction();
  }

  void call() {
    _checkErrorCode(_func(), 'InitializeCapturing');
  }
}

final InitializeCapturing = _InitializeCapturingWrapper();

class _FinalizeCapturingWrapper {

  late int Function() _func;

  _FinalizeCapturingWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function()>>('FSDK_FinalizeCapturing').asFunction();
  }

  void call() {
    _checkErrorCode(_func(), 'FinalizeCapturing');
  }
}

final FinalizeCapturing = _FinalizeCapturingWrapper();

class _SetParameterWrapper {

  late int Function(Pointer<Utf8>, Pointer<Utf8>) _func;

  _SetParameterWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Utf8>, Pointer<Utf8>)>>('FSDK_SetParameter').asFunction();
  }

  void call(String parameterName, dynamic parameterValue) {
    final var1 = parameterName.toNativeUtf8();
    final var2 = '$parameterValue'.toNativeUtf8();
    try {
      _checkErrorCode(_func(var1, var2), 'SetParameter');
    } finally {
      malloc.free(var2);
      malloc.free(var1);
    }
  }
}

final SetParameter = _SetParameterWrapper();

class _SetParametersWrapper {

  late int Function(Pointer<Utf8>, Pointer<Int32>) _func;

  _SetParametersWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Utf8>, Pointer<Int32>)>>('FSDK_SetParameters').asFunction();
  }

  void call(Map<String, dynamic> parameters) {
    final var1 = parameters.entries.map((entry) => '${entry.key}=${entry.value}').join(';').toNativeUtf8();
    final var2 = malloc.allocate<Int32>(sizeOf<Int32>());
    try {
      _checkErrorCode(_func(var1, var2), 'SetParameters', () => var2.value);
    } finally {
      malloc.free(var2);
      malloc.free(var1);
    }
  }
}

final SetParameters = _SetParametersWrapper();

Future<Directory> getCacheDirectory() async {
  final directory = await getApplicationCacheDirectory();
  return directory;
}

Future<bool> directoryExists(String path) async {
  final dir = Directory(path);
  if (await dir.exists()) {
    return true;
  }
  return false;
}

Future<String> _copyAssets() async 
{
  final cacheDir = await getCacheDirectory();

  final assetPaths = [
    'data/detection/ssd/ssd_new.conf',
    'data/detection/ssd/ssd_f8.conf',
    'data/internal/13db040b9a9b1f5e84218454df3a11d2627758e64df3de5a51e57afce4c01872',
    'data/internal/7b58eb1179ad97844e9705490830a97b61b83f8017b71a40733ba46c8da22420',
    'data/internal/caa80ea64c13d61bc6c341756abd3eb9b0aa0e252354b6cd1013018c73a03218',
    'data/internal/3692cda6cb9d19920044b5483337d9c20a92c4f92c5ea912ef87bffa897b79bc',
    'data/internal/7c3343b6ec7e331ac787501f9b3090a05b2d938e4ae1de59a121b87797803586',
    'data/internal/e5082d08f9c9486c186b740ef927f240bb5a498b3fde95a2f653aea21061f768',
    'data/internal/4235ac64f80d599ab219df183829af13e12a8c9b96d0eaf41988a83b9693592a',
    'data/internal/a4e42fe3ea6209e316056bc41cbe40a39c7159b2655756f08d100ff9883ed9ff',
    'data/internal/e911c1a0adf6bf47951b12e9c7ff48f38775f8d5d958dfc2d9018095b05c4035',
    'data/internal/51adfd9d6c77f4c7c439302292d6dcac30a5aea1f1816c6a2079d41bc1b8e747',
    'data/internal/aa6e956ba20a6190610da3dc3dc7e5bb4fb650cdfb467e56763883473d0df2c7',
    'data/internal/f21beb39325745062bcb0e2ea076f6413be89025a42d1ab1e1307183ddbe1a51',
    'data/internal/5ba89ae7a268036d96fae6de51d921f16aa11de643ffc95096ed0670bc55da88',
    'data/internal/ac3a38c3777a22e08c35cffaef9200ba51d89eb118966834a6603166c76010d1',
    'data/internal/f66284f5b1e14853d4aefecc549839145656388e4482855bc5de5d92752a8858',
    'data/internal/7484fdb5bb69d3283c8aacd885ee50d8ce53f21c7bbfc33509185fe239f2ad41',
    'data/internal/b333d4da1a385777d90cb4d335383cb28b10d5319f6a8417d963ed01b5abacdb',
    'data/pipelines/pegasus.json',
    'data/preprocessing/face_params.conf',
    'data/quality/exposition.conf'
  ];

  final dataDirectories = [
    'data/detection/ssd',
    'data/internal',
    'data/pipelines',
    'data/preprocessing',
    'data/quality',
  ];

  for (var d in dataDirectories) {
    var currentDir = '${cacheDir.path}/$d';
    var exists = await directoryExists(currentDir);
    if (!exists) {
      Directory(currentDir).createSync(recursive: true);
    }
  }

  var assetsPrefix = 'packages/flutter_face_sdk/';
  for (var assetPath in assetPaths) {

    var fullAssetName = assetsPrefix + assetPath;
    final file = File('${cacheDir.path}/$assetPath');
    if (await file.exists()) {
      continue;
    }

    final byteData = await rootBundle.load(fullAssetName);
    await file.writeAsBytes(byteData.buffer.asUint8List());
  }
  return cacheDir.path;
}

Future<String> PrepareData() async {
  final dataDirectory = await _copyAssets();
  return dataDirectory;
}
