/// Dart bindings for the Luxand FaceSDK with the iBeta liveness pipeline.
///
/// Most functions that return a native object also accept an optional named
/// parameter of that same type as their last argument. Every such object owns a
/// native allocation, so returning a fresh one means allocating on every call.
/// Passing an existing instance fills and returns that instead, which lets a
/// per-frame loop allocate once and reuse it:
///
/// ```dart
/// final face = Face.allocate();
/// for (final frame in frames) {
///   DetectFace(frame, face: face);
/// }
/// ```
///
/// Omit the parameter and a new instance is allocated for you, which is the
/// simpler choice outside hot paths.
library;

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
  static const IBetaInitialization = -200;

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

class IBetaInitializationError extends Error {
  IBetaInitializationError(String callee, [Object? info]) : super(Error.IBetaInitialization, callee, info);
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
  Error.FaceImageNotFound: (String callee, [Object? info]) => FaceImageNotFoundError(callee, info),
  Error.IBetaInitialization: (String callee, [Object? info]) => IBetaInitializationError(callee, info)
};

const FacialFeatureCount = 70;


/// A resource holding native memory that can be released early with `free`.
class Freeable {

  void free() {}

}

class _NativePointer<T extends NativeType> extends Freeable implements Finalizable {

  static final NativeFinalizer _finalizer = NativeFinalizer(malloc.nativeFree);

  final bool _owner;
  final Pointer<T> pointer;

  bool _freed = false;

  _NativePointer(this.pointer, [this._owner = false]) {
    if (_owner) {
      _finalizer.attach(this, pointer.cast(), detach: this);
    }
  }

  factory _NativePointer.fromAddress(int address) {
    return _NativePointer(Pointer<T>.fromAddress(address));
  }

  factory _NativePointer.allocate(int count) {
    return _NativePointer(malloc.allocate<T>(count), true);
  }

  @override
  void free() {
    if (_freed || !_owner) {
      return;
    }

    _freed = true;
    _finalizer.detach(this);
    malloc.free(pointer);
  }
}

/// The addresses of a buffer and its length, for sharing a buffer across isolates.
class BufferInfo {

  final int _dataAddress;
  final int _lengthAddress;

  BufferInfo(this._dataAddress, this._lengthAddress);

}

/// A byte buffer to be used with FSDK functions.
class DataBuffer extends ListBase<int> implements Freeable {

  late Uint8List _data;
  late _NativePointer<Int32> _length;
  late _NativePointer<Uint8> _nativeData;

  DataBuffer.allocate(int length) {
    _length = _NativePointer<Int32>.allocate(sizeOf<Int32>())..pointer.value = length;
    _nativeData = _NativePointer<Uint8>.allocate(sizeOf<Uint8>() * length);
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

    final newNativeData = _NativePointer<Uint8>.allocate(sizeOf<Uint8>() * newLength);
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

/// A buffer of 64 bit integers to be used with FSDK functions.
class Int64Buffer extends ListBase<int> implements Freeable {

  late Int64List _data;
  late _NativePointer<Int64> _length;
  late _NativePointer<Int64> _nativeData;

  Int64Buffer.allocate(int length) {
    _length = _NativePointer<Int64>.allocate(sizeOf<Int64>())..pointer.value = length;
    _nativeData = _NativePointer<Int64>.allocate(sizeOf<Int64>() * length);
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

    final newNativeData = _NativePointer<Int64>.allocate(sizeOf<Int64>() * newLength);
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

/// A point with integer coordinates.
final class Point extends Struct {

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

/// A point with floating point coordinates.
final class PointF extends Struct {

  @Float()
  external double x;

  @Float()
  external double y;

  static Pointer<PointF> allocate({required double x, required double y}) {
    final p = malloc<PointF>();
    p.ref.x = x;
    p.ref.y = y;
    return p;
  }
}

/// The five key points carried by a detected face.
final class FeaturePoints extends Struct {
  @Array(5)
  external Array<Point> points;
}

/// An axis-aligned bounding box given by two opposite corners.
final class BBox extends Struct {
  external Point p0, p1;
}

final class _Face extends Struct {

  @Float()
  external double score;

  @Float()
  external double angle;

  external BBox bbox;
  external FeaturePoints features;
}

/// A detected face: its bounding box, detection score and key points.
class Face extends Freeable {

  final _NativePointer<_Face> _nativePointer;

  BBox get bbox => _nativePointer.pointer.ref.bbox;
  List<Point> get features => _nativePointer.pointer.ref.features.points.elements;

  Face(this._nativePointer);

  factory Face.allocate() {
    return Face(_NativePointer<_Face>.allocate(sizeOf<_Face>()));
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

  int get width  => (bbox.p1.x - bbox.p0.x);
  int get height => (bbox.p1.y - bbox.p0.y);

  int get left => bbox.p0.x;
  int get top => bbox.p0.y;
  int get right => bbox.p1.x;
  int get bottom => bbox.p1.y;

  double get leftAsDouble => bbox.p0.x.toDouble();
  double get topAsDouble => bbox.p0.y.toDouble();
  double get rightAsDouble => bbox.p1.x.toDouble();
  double get bottomAsDouble => bbox.p1.y.toDouble();

  set left(int value) => bbox.p0.x = value;
  set top(int value) => bbox.p0.y = value;
  set right(int value) => bbox.p1.x = value;
  set bottom(int value) => bbox.p1.y = value;

  set features(List<Point> value) {
    for (var i = 0; i < 5; ++i){
      _nativePointer.pointer.ref.features.points[i] ..x = value[i].x ..y = value[i].y;
    }
  }

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

/// A list of detected faces.
class Faces extends ListBase<Face> implements Freeable {

  late int _capacity;
  late _NativePointer<Int32> _length;
  late _NativePointer<_Face> _nativeData;

  Faces.allocate(int length) {
    _capacity = length;
    _length = _NativePointer<Int32>.allocate(sizeOf<Int32>())..pointer.value = length;
    _nativeData = _NativePointer<_Face>.allocate(sizeOf<_Face>() * length);
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

    final newNativeData = _NativePointer<_Face>.allocate(sizeOf<_Face>() * newLength);
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
    return Face.fromPointer(pointer + index);
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

/// The facial key points detected for a face.
class FacialFeatures extends ListBase<PointF> implements Freeable {

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

  _NativePointer<PointF> _nativePointer;

  FacialFeatures(this._nativePointer);

  factory FacialFeatures.allocate() {
    return FacialFeatures(_NativePointer<PointF>.allocate(sizeOf<PointF>() * FacialFeatureCount));
  }

  factory FacialFeatures._allocate() {
    return FacialFeatures.allocate();
  }

  factory FacialFeatures.fromPointer(Pointer<PointF> pointer) {
    return FacialFeatures(_NativePointer<PointF>(pointer));
  }

  factory FacialFeatures.fromAddress(int address) {
    return FacialFeatures(_NativePointer<PointF>.fromAddress(address));
  }

  @override
  int get length => FacialFeatureCount;

  @override
  set length(int newLength) {
    throw UnsupportedError('Cannot resize FacialFeatures object');
  }

  Pointer<PointF> get pointer => _nativePointer.pointer;

  @override
  PointF operator [](int index) => pointer[index];

  @override
  void operator []=(int index, PointF point) {
    final value = pointer[index];
    value.x = point.x;
    value.y = point.y;
  }

  @override
  void free() {
    _nativePointer.free();
  }

}

/// A face template representing a person.
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

  /// Get the similarity score between this template and another.
  ///
  /// - [other] the template to compare against
  double match(FaceTemplate other) {
    return MatchFaces(this, other);
  }

  @override
  void free() {
    _buffer.free();
  }

}

/// A face image extracted from a larger image, with its key points.
class ExtractedFace {

  final Image image;
  final FacialFeatures features;

  ExtractedFace(this.image, this.features);

}

/// A tracker id and how similar it is to a queried template.
final class IDSimilarity extends Struct {
  @Int64()
  external int id;

  @Float()
  external double similarity;
}

/// A list of tracker ids ranked by similarity.
class IDSimilarities extends ListBase<IDSimilarity> implements Freeable {

  late int _capacity;
  late _NativePointer<Int64> _length;
  late _NativePointer<IDSimilarity> _nativeData;

  IDSimilarities.allocate(int length) {
    _capacity = length;
    _length = _NativePointer<Int64>.allocate(sizeOf<Int64>())..pointer.value = length;
    _nativeData = _NativePointer<IDSimilarity>.allocate(sizeOf<IDSimilarity>() * length);
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

    final newNativeData = _NativePointer<IDSimilarity>.allocate(sizeOf<IDSimilarity>() * newLength);
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

/// A wrapper object for an FSDK image.
class Image extends Freeable {

  late _NativePointer<Uint32> _native;

  Image._fromNativePointer(_NativePointer<Uint32> pointer) {
    _native = pointer;
  }

  factory Image._allocate() {
    return Image._fromNativePointer(_NativePointer<Uint32>.allocate(sizeOf<Uint32>()));
  }

  factory Image.fromHandle(int handle) {
    return Image._fromNativePointer(_NativePointer<Uint32>.allocate(sizeOf<Uint32>())..pointer.value = handle);
  }

  factory Image.fromPointer(Pointer<Uint32> pointer) {
    return Image._fromNativePointer(_NativePointer<Uint32>(pointer));
  }

  int get handle => _native.pointer.value;
  Pointer<Uint32> get pointer => _native.pointer;

  factory Image({Image? image}) {
    return CreateEmptyImage(image: image);
  }

  /// Free the internal image buffer. The image becomes invalid.
  ///
  /// - [freePointer] false to release the native image but keep the handle cell alive
  @override
  void free({bool freePointer = true}) {
    FreeImage(this);
    if (freePointer) {
      _native.free();
    }
  }

  /// Load an image from a file.
  ///
  /// - [fileName] path to the file
  /// - [image] optional instance to fill and return; reusing one across calls skips an allocation
  factory Image.fromFile(String fileName, {Image? image}) {
    return LoadImageFromFile(fileName, image: image);
  }

  /// Load an image from a file, preserving its alpha channel.
  ///
  /// - [fileName] path to the file
  /// - [image] optional instance to fill and return; reusing one across calls skips an allocation
  factory Image.fromFileWithAlpha(String fileName, {Image? image}) {
    return LoadImageFromFileWithAlpha(fileName, image: image);
  }

  /// Save the image into a file.
  ///
  /// - [fileName] path to the file
  void saveToFile(String fileName) {
    SaveImageToFile(this, fileName);
  }

  /// Get image width.
  int get width {
    return GetImageWidth(this);
  }

  /// Get image height.
  int get height {
    return GetImageHeight(this);
  }

  /// Get a view over the image's own pixel buffer.
  ///
  /// The view is not a copy: it stays valid only while the image is left untouched.
  ImageData getData() {
    return GetImageData(this);
  }

  /// Load an image from a raw pixel buffer.
  ///
  /// - [buffer] the bytes to read from
  /// - [width] width in pixels
  /// - [height] height in pixels
  /// - [scanLine] number of bytes per row in [buffer]
  /// - [imageMode] the pixel format to encode with
  /// - [image] optional instance to fill and return; reusing one across calls skips an allocation
  factory Image.fromBuffer(DataBuffer buffer, int width, int height, int scanLine, ImageMode imageMode, {Image? image}) {
    return LoadImageFromBuffer(buffer, width, height, scanLine, imageMode, image: image);
  }

  /// Get the size in bytes of a buffer encoding the image in the given format.
  ///
  /// - [imageMode] the pixel format to encode with
  int getBufferSize(ImageMode imageMode) {
    return GetImageBufferSize(this, imageMode);
  }

  /// Save the image into a byte buffer.
  ///
  /// - [imageMode] the pixel format to encode with
  /// - [buffer] optional instance to fill and return; reusing one across calls skips an allocation
  DataBuffer saveToBuffer(ImageMode imageMode, {DataBuffer? buffer}) {
    return SaveImageToBuffer(this, imageMode, buffer: buffer);
  }

  /// Load an image from a JPEG encoded buffer.
  ///
  /// - [buffer] the bytes to read from
  /// - [image] optional instance to fill and return; reusing one across calls skips an allocation
  factory Image.fromJpegBuffer(DataBuffer buffer, {Image? image}) {
    return LoadImageFromJpegBuffer(buffer, image: image);
  }

  /// Load an image from a PNG encoded buffer.
  ///
  /// - [buffer] the bytes to read from
  /// - [image] optional instance to fill and return; reusing one across calls skips an allocation
  factory Image.fromPngBuffer(DataBuffer buffer, {Image? image}) {
    return LoadImageFromPngBuffer(buffer, image: image);
  }

  /// Load an image from a PNG encoded buffer, preserving its alpha channel.
  ///
  /// - [buffer] the bytes to read from
  /// - [image] optional instance to fill and return; reusing one across calls skips an allocation
  factory Image.fromPngBufferWithAlpha(DataBuffer buffer, {Image? image}) {
    return LoadImageFromPngBufferWithAlpha(buffer, image: image);
  }

  /// Detect a single face. If several are present, returns the highest scoring one.
  ///
  /// - [face] optional instance to fill and return; reusing one across calls skips an allocation
  Face detectFace({Face? face}) {
    return DetectFace(this, face: face);
  }

  /// Detect multiple faces, sorted by detection score descending.
  ///
  /// - [faces] optional instance to fill and return; reusing one across calls skips an allocation
  /// - [maxSize] the most results to return
  Faces detectMultipleFaces({Faces? faces, int maxSize = 256}) {
    return DetectMultipleFaces(this, faces: faces, maxSize: maxSize);
  }

  /// Detect the facial key points of a single face.
  ///
  /// - [facialFeatures] optional instance to fill and return; reusing one across calls skips an allocation
  FacialFeatures detectFacialFeatures({FacialFeatures? facialFeatures}) {
    return DetectFacialFeatures(this, facialFeatures: facialFeatures);
  }

  /// Detect the facial key points of a given face.
  ///
  /// - [face] the face region to work within
  /// - [facialFeatures] optional instance to fill and return; reusing one across calls skips an allocation
  FacialFeatures detectFacialFeaturesInRegion(Face face, {FacialFeatures? facialFeatures}) {
    return DetectFacialFeaturesInRegion(this, face, facialFeatures: facialFeatures);
  }

  /// Create a copy of the image.
  Image copy() {
    return CopyImage(this);
  }

  /// Create a new image scaled by `ratio`.
  ///
  /// - [ratio] scale factor, where 1.0 keeps the original size
  Image resize(double ratio) {
    return ResizeImage(this, ratio);
  }

  /// Create a new image rotated by 90 * `multiplier` degrees. Negative values rotate
  /// counterclockwise.
  ///
  /// - [multiplier] number of 90 degree steps; negative values rotate counterclockwise
  Image rotate90(int multiplier) {
    return RotateImage90(this, multiplier);
  }

  /// Create a new image rotated `angle` degrees around the center.
  ///
  /// - [angle] rotation in degrees
  Image rotate(double angle) {
    return RotateImage(this, angle);
  }

  /// Create a new image rotated `angle` degrees around (`xCenter`, `yCenter`).
  ///
  /// - [angle] rotation in degrees
  /// - [xCenter] x coordinate to rotate around
  /// - [yCenter] y coordinate to rotate around
  Image rotateCenter(double angle, double xCenter, double yCenter) {
    return RotateImageCenter(this, angle, xCenter, yCenter);
  }

  /// Copy the axis-aligned rectangle bounded by (`x1`, `y1`) and (`x2`, `y2`).
  ///
  /// - [x1] left edge of the rectangle
  /// - [y1] top edge of the rectangle
  /// - [x2] right edge of the rectangle
  /// - [y2] bottom edge of the rectangle
  Image copyRect(int x1, int y1, int x2, int y2) {
    return CopyRect(this, x1, y1, x2, y2);
  }

  /// As `copyRect`, but parts outside the image repeat the border pixels.
  ///
  /// - [x1] left edge of the rectangle
  /// - [y1] top edge of the rectangle
  /// - [x2] right edge of the rectangle
  /// - [y2] bottom edge of the rectangle
  Image copyRectReplicateBorder(int x1, int y1, int x2, int y2) {
    return CopyRectReplicateBorder(this, x1, y1, x2, y2);
  }

  /// Mirror the image around the vertical or horizontal axis.
  ///
  /// - [useVerticalMirroringInsteadOfHorizontal] true to mirror around the vertical axis, false for the horizontal one
  void mirror(bool useVerticalMirroringInsteadOfHorizontal) {
    MirrorImage(this, useVerticalMirroringInsteadOfHorizontal);
  }

  /// Extract the part of the image containing the face, resized to `width` x `height`.
  ///
  /// - [facialFeatures] the key points locating the face in this image
  /// - [width] width of the extracted image
  /// - [height] height of the extracted image
  /// - [extractedFaceImage] optional instance to fill and return; reusing one across calls skips an allocation
  /// - [resizedFeatures] optional instance to fill and return; reusing one across calls skips an allocation
  ExtractedFace extractFace(FacialFeatures facialFeatures, int width, int height, {Image? extractedFaceImage, FacialFeatures? resizedFeatures}) {
    return ExtractFaceImage(this, facialFeatures, width, height, extractedFaceImage: extractedFaceImage, resizedFeatures: resizedFeatures);
  }

  /// Get the face template of a single face.
  ///
  /// - [faceTemplate] optional instance to fill and return; reusing one across calls skips an allocation
  FaceTemplate getFaceTemplate({FaceTemplate? faceTemplate}) {
    return GetFaceTemplate(this, faceTemplate: faceTemplate);
  }

  /// Get the face template of a given face.
  ///
  /// - [face] the face region to work within
  /// - [faceTemplate] optional instance to fill and return; reusing one across calls skips an allocation
  FaceTemplate getFaceTemplateInRegion(Face face, {FaceTemplate? faceTemplate}) {
    return GetFaceTemplateInRegion(this, face, faceTemplate: faceTemplate);
  }

  /// Detect facial attribute values using facial key points.
  ///
  /// - [facialFeatures] the facial key points to work from
  /// - [attributeName] the attribute to query, such as `Gender` or `Liveness`
  /// - [maxSizeInBytes] size of the buffer allocated for the result
  String detectFacialAttributeUsingFeatures(FacialFeatures facialFeatures, String attributeName, {int maxSizeInBytes = 256}) {
    return DetectFacialAttributeUsingFeatures(this, facialFeatures, attributeName, maxSizeInBytes: maxSizeInBytes);
  }

}

/// A wrapper object for an FSDK video camera.
class Camera extends Freeable {

  late _NativePointer<Int32> _native;

  Camera._fromNativePointer(_NativePointer<Int32> pointer) {
    _native = pointer;
  }

  factory Camera._allocate() {
    return Camera._fromNativePointer(_NativePointer<Int32>.allocate(sizeOf<Int32>()));
  }

  factory Camera.fromHandle(int handle) {
    return Camera._fromNativePointer(_NativePointer<Int32>.allocate(sizeOf<Int32>())..pointer.value = handle);
  }

  factory Camera.fromPointer(Pointer<Int32> pointer) {
    return Camera._fromNativePointer(_NativePointer<Int32>(pointer));
  }

  int get handle => _native.pointer.value;
  Pointer<Int32> get pointer => _native.pointer;

  factory Camera.openIP(VideoCompressionType compressionType, String url, String username, String password, int timeoutSeconds, {Camera? cameraHandle}) {
    return OpenIPVideoCamera(compressionType, url, username, password, timeoutSeconds, cameraHandle: cameraHandle);
  }

  /// Close the camera. It becomes invalid.
  void close() {
    CloseVideoCamera(this);
  }

  /// Grab a frame from the camera.
  ///
  /// - [image] optional instance to fill and return; reusing one across calls skips an allocation
  Image grabFrame({Image? image}) {
    return GrabFrame(this, image: image);
  }

}

/// A wrapper object for an FSDK tracker.
class Tracker extends Freeable {

  late _NativePointer<Uint32> _native;

  Tracker._fromNativePointer(_NativePointer<Uint32> pointer) {
    _native = pointer;
  }

  factory Tracker._allocate() {
    return Tracker._fromNativePointer(_NativePointer<Uint32>.allocate(sizeOf<Uint32>()));
  }

  factory Tracker.fromHandle(int handle) {
    return Tracker._fromNativePointer(_NativePointer<Uint32>.allocate(sizeOf<Uint32>())..pointer.value = handle);
  }

  factory Tracker.fromPointer(Pointer<Uint32> pointer) {
    return Tracker._fromNativePointer(_NativePointer<Uint32>(pointer));
  }

  int get handle => _native.pointer.value;
  Pointer<Uint32> get pointer => _native.pointer;

  factory Tracker({Tracker? tracker}) {
    return CreateTracker(tracker: tracker);
  }

  /// Free the tracker. It becomes invalid.
  ///
  /// - [freePointer] false to release the native tracker but keep the handle cell alive
  @override
  void free({bool freePointer = true}) {
    FreeTracker(this);
    if (freePointer) {
      _native.free();
    }
  }

  /// Clear the tracker's memory.
  void clear() {
    ClearTracker(this);
  }

  /// Set a tracker parameter.
  ///
  /// - [parameterName] the name of the parameter
  /// - [parameterValue] the value to set
  void setParameter(String parameterName, String parameterValue) {
    SetTrackerParameter(this, parameterName, parameterValue);
  }

  /// Set several tracker parameters at once.
  ///
  /// - [parameters] the parameters to set, as name/value pairs
  void setMultipleParameters(Map<String, dynamic> parameters) {
    SetTrackerMultipleParameters(this, parameters);
  }

  /// Get a tracker parameter.
  ///
  /// - [parameterName] the name of the parameter
  /// - [maxSizeInBytes] size of the buffer allocated for the result
  String getParameter(String parameterName, {int maxSizeInBytes = 256}) {
    return GetTrackerParameter(this, parameterName, maxSizeInBytes: maxSizeInBytes);
  }

  /// Feed a frame to the tracker, returning the ids detected in it.
  ///
  /// - [cameraIdx] the camera index the frame was fed with
  /// - [image] the image to operate on
  /// - [ids] optional instance to fill and return; reusing one across calls skips an allocation
  /// - [maxSize] the most results to return
  Int64Buffer feedFrame(int cameraIdx, Image image, {Int64Buffer? ids, int maxSize = 256}) {
    return FeedFrame(this, cameraIdx, image, ids: ids, maxSize: maxSize);
  }

  /// Get the facial key points detected for an id.
  ///
  /// - [cameraIdx] the camera index the frame was fed with
  /// - [id] the tracker id identifying a person
  /// - [facialFeatures] optional instance to fill and return; reusing one across calls skips an allocation
  FacialFeatures getFacialFeatures(int cameraIdx, int id, {FacialFeatures? facialFeatures}) {
    return GetTrackerFacialFeatures(this, cameraIdx, id, facialFeatures: facialFeatures);
  }

  /// Get the eye centers detected for an id.
  ///
  /// Only the [FacialFeatures.LeftEye] and [FacialFeatures.RightEye] entries are written.
  ///
  /// - [cameraIdx] the camera index the frame was fed with
  /// - [id] the tracker id identifying a person
  /// - [facialFeatures] optional instance to fill and return; reusing one across calls skips an allocation
  FacialFeatures getEyes(int cameraIdx, int id, {FacialFeatures? facialFeatures}) {
    return GetTrackerEyes(this, cameraIdx, id, facialFeatures: facialFeatures);
  }

  /// Get the face detected for an id.
  ///
  /// - [cameraIdx] the camera index the frame was fed with
  /// - [id] the tracker id identifying a person
  /// - [face] optional instance to fill and return; reusing one across calls skips an allocation
  Face getFace(int cameraIdx, int id, {Face? face}) {
    return GetTrackerFace(this, cameraIdx, id, face: face);
  }

  /// Prevent an id from being reassigned or purged.
  ///
  /// - [id] the tracker id identifying a person
  void lockID(int id) {
    LockID(this, id);
  }

  /// Release a lock previously taken with `lockID`.
  ///
  /// - [id] the tracker id identifying a person
  void unlockID(int id) {
    UnlockID(this, id);
  }

  /// Remove an id from the tracker's memory.
  ///
  /// - [id] the tracker id identifying a person
  void purgeID(int id) {
    PurgeID(this, id);
  }

  /// Set the name associated with an id.
  ///
  /// - [id] the tracker id identifying a person
  /// - [name] the name to associate with the id
  void setName(int id, String name) {
    SetName(this, id, name);
  }

  /// Get the name associated with an id.
  ///
  /// - [id] the tracker id identifying a person
  /// - [maxSizeInBytes] size of the buffer allocated for the result
  String getName(int id, {int maxSizeInBytes = 256}) {
    return GetName(this, id, maxSizeInBytes: maxSizeInBytes);
  }

  /// Get every name associated with an id.
  ///
  /// - [id] the tracker id identifying a person
  /// - [maxSizeInBytes] size of the buffer allocated for the result
  String getAllNames(int id, {int maxSizeInBytes = 256}) {
    return GetAllNames(this, id, maxSizeInBytes: maxSizeInBytes);
  }

  /// Get the id this id was reassigned to, if any.
  ///
  /// - [id] the tracker id identifying a person
  int getIDReassignment(int id) {
    return GetIDReassignment(this, id);
  }

  /// Get the number of ids considered similar to this one.
  ///
  /// - [id] the tracker id identifying a person
  int getSimilarIDCount(int id) {
    return GetSimilarIDCount(this, id);
  }

  /// Get the ids considered similar to this one.
  ///
  /// - [id] the tracker id identifying a person
  /// - [similarIDList] optional instance to fill and return; reusing one across calls skips an allocation
  Int64Buffer getSimilarIDList(int id, {Int64Buffer? similarIDList}) {
    return GetSimilarIDList(this, id, similarIDList: similarIDList);
  }

  /// Save tracker memory to a file.
  ///
  /// - [fileName] path to the file
  void saveToFile(String fileName) {
    SaveTrackerMemoryToFile(this, fileName);
  }

  /// Load tracker memory from a file.
  ///
  /// - [fileName] path to the file
  /// - [tracker] optional instance to fill and return; reusing one across calls skips an allocation
  factory Tracker.fromFile(String fileName, {Tracker? tracker}) {
    return LoadTrackerMemoryFromFile(fileName, tracker: tracker);
  }

  /// Get the size in bytes needed to store the tracker's memory.
  int get bufferSize {
    return GetTrackerMemoryBufferSize(this);
  }

  /// Save tracker memory to a buffer.
  ///
  /// - [buffer] optional instance to fill and return; reusing one across calls skips an allocation
  DataBuffer saveToBuffer({DataBuffer? buffer}) {
    return SaveTrackerMemoryToBuffer(this, buffer: buffer);
  }

  /// Load tracker memory from a buffer.
  ///
  /// - [buffer] the bytes to read from
  /// - [tracker] optional instance to fill and return; reusing one across calls skips an allocation
  factory Tracker.fromBuffer(DataBuffer buffer, {Tracker? tracker}) {
    return LoadTrackerMemoryFromBuffer(buffer, tracker: tracker);
  }

  /// Get facial attribute values (angles, liveness, ...) for an id.
  ///
  /// - [cameraIdx] the camera index the frame was fed with
  /// - [id] the tracker id identifying a person
  /// - [attributeName] the attribute to query, such as `Gender` or `Liveness`
  /// - [maxSizeInBytes] size of the buffer allocated for the result
  String getFacialAttribute(int cameraIdx, int id, String attributeName, {int maxSizeInBytes = 256}) {
    return GetTrackerFacialAttribute(this, cameraIdx, id, attributeName, maxSizeInBytes: maxSizeInBytes);
  }

  /// Get the number of ids held by the tracker.
  int getIDsCount() {
    return GetTrackerIDsCount(this);
  }

  /// Get every id held by the tracker.
  Int64Buffer getAllIDs() {
    return GetTrackerAllIDs(this);
  }

  /// Get the number of face ids stored for an id.
  ///
  /// - [id] the tracker id identifying a person
  int getFaceIDsCountForID(int id) {
    return GetTrackerFaceIDsCountForID(this, id);
  }

  /// Get the face ids stored for an id.
  ///
  /// - [id] the tracker id identifying a person
  Int64Buffer getFaceIDsForID(int id, {Int64Buffer}) {
    return GetTrackerFaceIDsForID(this, id);
  }

  /// Get the id a face id belongs to.
  ///
  /// - [faceID] the face id identifying one stored face of a person
  int getIDByFaceID(int faceID) {
    return GetTrackerIDByFaceID(this, faceID);
  }

  /// Get the face template stored for a face id.
  ///
  /// - [faceID] the face id identifying one stored face of a person
  /// - [faceTemplate] optional instance to fill and return; reusing one across calls skips an allocation
  FaceTemplate getFaceTemplate(int faceID, {FaceTemplate? faceTemplate}) {
    return GetTrackerFaceTemplate(this, faceID, faceTemplate: faceTemplate);
  }

  /// Get the face image stored for a face id.
  ///
  /// - [faceID] the face id identifying one stored face of a person
  /// - [image] optional instance to fill and return; reusing one across calls skips an allocation
  Image getFaceImage(int faceID, {Image? image}) {
    return GetTrackerFaceImage(this, faceID, image: image);
  }

  /// Store a face image for a face id.
  ///
  /// - [faceID] the face id identifying one stored face of a person
  /// - [faceImage] the image to store
  void setFaceImage(int faceID, Image faceImage) {
    SetTrackerFaceImage(this, faceID, faceImage);
  }

  /// Delete the face image stored for a face id.
  ///
  /// - [faceID] the face id identifying one stored face of a person
  void deleteFaceImage(int faceID) {
    DeleteTrackerFaceImage(this, faceID);
  }

  /// Create a new id from a face template.
  ///
  /// - [faceTemplate] the face template to use
  TrackerCreateIDResult createID(FaceTemplate faceTemplate) {
    return TrackerCreateID(this, faceTemplate);
  }

  /// Add a face template to an existing id.
  ///
  /// - [id] the tracker id identifying a person
  /// - [faceTemplate] the face template to use
  int addFaceTemplate(int id, FaceTemplate faceTemplate) {
    return AddTrackerFaceTemplate(this, id, faceTemplate);
  }

  /// Delete a face from the tracker's memory.
  ///
  /// - [faceID] the face id identifying one stored face of a person
  void deleteFace(int faceID) {
    DeleteTrackerFace(this, faceID);
  }

  /// Match a template against the tracker's memory.
  ///
  /// - [faceTemplate] the face template to use
  /// - [threshold] the lowest similarity worth returning
  /// - [idSimilarities] optional instance to fill and return; reusing one across calls skips an allocation
  /// - [maxCount] the most results to return
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

/// Activate the library with a license key. Must be called before any other function.
///
/// - [licenseKey] the license key to activate with
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

/// Get this device's hardware id, used when requesting a license.
///
/// - [maxSize] the most results to return
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

/// Get information about the active license.
///
/// - [maxSize] the most results to return
final GetLicenseInfo = _GetLicenseInfoWrapper();

class _GetVersionInfoWrapper {

  late int Function(Pointer<Pointer<Utf8>>) _func;

  _GetVersionInfoWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Pointer<Utf8>>)>>('FSDK_GetVersionInfo').asFunction();
  }

  String call() {
    final var1 = malloc.allocate<Pointer<Utf8>>(1);
    try {
      _checkErrorCode(_func(var1), 'GetVersionInfo');
      return var1.value.toDartString();
    } finally {
      malloc.free(var1);
    }
  }
}

/// Get the FaceSDK version string.
final GetVersionInfo = _GetVersionInfoWrapper();

class _SetNumThreadsWrapper {

  late int Function(int) _func;

  _SetNumThreadsWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Int32)>>('FSDK_SetNumThreads').asFunction();
  }

  void call(int num) {
    _checkErrorCode(_func(num), 'SetNumThreads');
  }
}

/// Set the maximum number of threads the SDK may use.
///
/// - [num] the number of threads
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

/// Get the maximum number of threads the SDK may use.
final GetNumThreads = _GetNumThreadsWrapper();

class _InitializeWrapper {

  late int Function(Pointer<Utf8>) _func;

  _InitializeWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Utf8>)>>('FSDK_Initialize').asFunction();
  }

  void call({String? dataFilesPath}) {
    final var1 = dataFilesPath == null ? nullptr : dataFilesPath.toNativeUtf8();
    try {
      _checkErrorCode(_func(var1.cast()), 'Initialize');
    } finally {
      if (var1 != nullptr) {
        malloc.free(var1);
      }
    }
  }
}

/// Initialize the library. Call after `ActivateLibrary`.
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

/// Finalize the library and release the resources it holds.
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

/// Create a new empty image.
///
/// - [image] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Free the internal image buffer. The image becomes invalid.
///
/// - [image] the image to release
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

/// Load an image from a file.
///
/// - [fileName] path to the file
/// - [image] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Load an image from a file, preserving its alpha channel.
///
/// - [fileName] path to the file
/// - [image] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Save the image into a file.
///
/// - [image] the image to operate on
/// - [fileName] path to the file
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

/// Set the JPEG quality used when saving images.
///
/// - [quality] JPEG quality, where higher values keep more detail
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

/// Get image width.
///
/// - [image] the image to operate on
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

/// Get image height.
///
/// - [image] the image to operate on
final GetImageHeight = _GetImageHeightWrapper();

/// A view over an image's own pixel buffer.
///
/// The memory belongs to the image, so the view stays valid only while the image
/// is left untouched. Copy out of it before modifying or freeing the image.
class ImageData {

  final Pointer<Uint8> pointer;
  final int width;
  final int height;
  final int scanLine;
  final ImageMode imageMode;

  ImageData(this.pointer, this.width, this.height, this.scanLine, this.imageMode);

  /// The pixel bytes, as a view over the image's buffer rather than a copy.
  Uint8List asUint8List() => pointer.asTypedList(scanLine * height);

}

class _GetImageDataWrapper {

  late int Function(int, Pointer<Pointer<Uint8>>, Pointer<Int32>, Pointer<Int32>, Pointer<Int32>, Pointer<Int32>) _func;

  _GetImageDataWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Pointer<Uint8>>, Pointer<Int32>, Pointer<Int32>, Pointer<Int32>, Pointer<Int32>)>>('FSDK_GetImageData').asFunction();
  }

  ImageData call(Image image) {
    final var1 = malloc.allocate<Pointer<Uint8>>(sizeOf<Pointer<Uint8>>());
    final var2 = malloc.allocate<Int32>(sizeOf<Int32>() * 4);
    try {
      _checkErrorCode(_func(image.handle, var1, var2, var2 + 1, var2 + 2, var2 + 3), 'GetImageData');
      return ImageData(var1.value, var2[0], var2[1], var2[2], ImageMode.values[var2[3]]);
    } finally {
      malloc.free(var2);
      malloc.free(var1);
    }
  }
}

/// Get a view over the image's own pixel buffer, along with its dimensions and
/// pixel format. The buffer is not copied and belongs to the image.
///
/// - [image] the image to read from
final GetImageData = _GetImageDataWrapper();

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

/// Load an image from a raw pixel buffer.
///
/// - [buffer] the raw pixel bytes to load
/// - [width] width in pixels
/// - [height] height in pixels
/// - [scanLine] number of bytes per row in [buffer]
/// - [imageMode] the pixel format of [buffer]
/// - [image] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Get the size in bytes of a buffer encoding the image in the given format.
///
/// - [image] the image to operate on
/// - [imageMode] the pixel format to measure for
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

/// Save the image into a byte buffer.
///
/// - [image] the image to operate on
/// - [imageMode] the pixel format to encode with
/// - [buffer] optional instance to fill and return; reusing one across calls skips an allocation
final SaveImageToBuffer = _SaveImageToBufferWrapper();

class _LoadImageFromJpegBufferWrapper {

  late int Function(Pointer<Uint32>, Pointer<Uint8>, int) _func;

  _LoadImageFromJpegBufferWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>, Pointer<Uint8>, Uint32)>>('FSDK_LoadImageFromJpegBuffer').asFunction();
  }

  Image call(DataBuffer buffer, {Image? image}) {
    image ??= Image._allocate();
    _checkErrorCode(_func(image.pointer, buffer.pointer, buffer.length), 'LoadImageFromJpegBuffer');
    return image;
  }
}

/// Load an image from a JPEG encoded buffer.
///
/// - [buffer] the JPEG encoded bytes to load
/// - [image] optional instance to fill and return; reusing one across calls skips an allocation
final LoadImageFromJpegBuffer = _LoadImageFromJpegBufferWrapper();

class _LoadImageFromPngBufferWrapper {

  late int Function(Pointer<Uint32>, Pointer<Uint8>, int) _func;

  _LoadImageFromPngBufferWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>, Pointer<Uint8>, Uint32)>>('FSDK_LoadImageFromPngBuffer').asFunction();
  }

  Image call(DataBuffer buffer, {Image? image}) {
    image ??= Image._allocate();
    _checkErrorCode(_func(image.pointer, buffer.pointer, buffer.length), 'LoadImageFromPngBuffer');
    return image;
  }
}

/// Load an image from a PNG encoded buffer.
///
/// - [buffer] the PNG encoded bytes to load
/// - [image] optional instance to fill and return; reusing one across calls skips an allocation
final LoadImageFromPngBuffer = _LoadImageFromPngBufferWrapper();

class _LoadImageFromPngBufferWithAlphaWrapper {

  late int Function(Pointer<Uint32>, Pointer<Uint8>, int) _func;

  _LoadImageFromPngBufferWithAlphaWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Uint32>, Pointer<Uint8>, Uint32)>>('FSDK_LoadImageFromPngBufferWithAlpha').asFunction();
  }

  Image call(DataBuffer buffer, {Image? image}) {
    image ??= Image._allocate();
    _checkErrorCode(_func(image.pointer, buffer.pointer, buffer.length), 'LoadImageFromPngBufferWithAlpha');
    return image;
  }
}

/// Load an image from a PNG encoded buffer, preserving its alpha channel.
///
/// - [buffer] the PNG encoded bytes to load
/// - [image] optional instance to fill and return; reusing one across calls skips an allocation
final LoadImageFromPngBufferWithAlpha = _LoadImageFromPngBufferWithAlphaWrapper();

class _DetectFaceWrapper {

  late int Function(int, Pointer<_Face>) _func;

  _DetectFaceWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<_Face>)>>('FSDK_DetectFace').asFunction();
  }

  Face call(Image image, {Face? face}) {
    face ??= Face._allocate();
    _checkErrorCode(_func(image.handle, face.pointer), 'DetectFace');
    return face;
  }
}

/// Detect a single face. If several are present, returns the highest scoring one.
///
/// - [image] the image to operate on
/// - [face] optional instance to fill and return; reusing one across calls skips an allocation
final DetectFace = _DetectFaceWrapper();

class _DetectMultipleFacesWrapper {

  late int Function(int, Pointer<Int32>, Pointer<_Face>, int) _func;

  _DetectMultipleFacesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Int32>, Pointer<_Face>, Int32)>>('FSDK_DetectMultipleFaces').asFunction();
  }

  Faces call(Image image, {Faces? faces, int maxSize = 256}) {
    faces ??= Faces._allocate(maxSize);
    _checkErrorCode(_func(image.handle, faces._lengthPointer, faces.pointer, faces.capacity), 'DetectMultipleFaces');
    return faces;
  }
}

/// Detect multiple faces, sorted by detection score descending.
///
/// - [image] the image to operate on
/// - [faces] optional instance to fill and return; reusing one across calls skips an allocation
/// - [maxSize] the most results to return
final DetectMultipleFaces = _DetectMultipleFacesWrapper();

class _DetectFacialFeaturesWrapper {

  late int Function(int, Pointer<PointF>) _func;

  _DetectFacialFeaturesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<PointF>)>>('FSDK_DetectFacialFeatures').asFunction();
  }

  FacialFeatures call(Image image, {FacialFeatures? facialFeatures}) {
    facialFeatures ??= FacialFeatures._allocate();
    _checkErrorCode(_func(image.handle, facialFeatures.pointer), 'DetectFacialFeatures');
    return facialFeatures;
  }
}

/// Detect the facial key points of a single face.
///
/// - [image] the image to operate on
/// - [facialFeatures] optional instance to fill and return; reusing one across calls skips an allocation
final DetectFacialFeatures = _DetectFacialFeaturesWrapper();

class _DetectFacialFeaturesInRegionWrapper {

  late int Function(int, Pointer<_Face>, Pointer<PointF>) _func;

  _DetectFacialFeaturesInRegionWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<_Face>, Pointer<PointF>)>>('FSDK_DetectFacialFeaturesInRegion').asFunction();
  }

  FacialFeatures call(Image image, Face face, {FacialFeatures? facialFeatures}) {
    facialFeatures ??= FacialFeatures._allocate();
    _checkErrorCode(_func(image.handle, face.pointer, facialFeatures.pointer), 'DetectFacialFeaturesInRegion');
    return facialFeatures;
  }
}

/// Detect the facial key points of a given face.
///
/// - [image] the image to operate on
/// - [face] the face region to work within
/// - [facialFeatures] optional instance to fill and return; reusing one across calls skips an allocation
final DetectFacialFeaturesInRegion = _DetectFacialFeaturesInRegionWrapper();

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

/// Create a copy of the image.
///
/// - [sourceImage] the image to read from
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

/// Create a new image scaled by `ratio`.
///
/// - [sourceImage] the image to read from
/// - [ratio] scale factor, where 1.0 keeps the original size
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

/// Create a new image rotated by 90 * `multiplier` degrees. Negative values rotate
/// counterclockwise.
///
/// - [sourceImage] the image to read from
/// - [multiplier] number of 90 degree steps; negative values rotate counterclockwise
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

/// Create a new image rotated `angle` degrees around the center.
///
/// - [sourceImage] the image to read from
/// - [angle] rotation in degrees
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

/// Create a new image rotated `angle` degrees around (`x`, `y`).
///
/// - [sourceImage] the image to read from
/// - [angle] rotation in degrees
/// - [xCenter] x coordinate to rotate around
/// - [yCenter] y coordinate to rotate around
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

/// Copy the axis-aligned rectangle bounded by (`x1`, `y1`) and (`x2`, `y2`).
///
/// - [sourceImage] the image to read from
/// - [x1] left edge of the rectangle
/// - [y1] top edge of the rectangle
/// - [x2] right edge of the rectangle
/// - [y2] bottom edge of the rectangle
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

/// As `CopyRect`, but parts outside the image repeat the border pixels.
///
/// - [sourceImage] the image to read from
/// - [x1] left edge of the rectangle
/// - [y1] top edge of the rectangle
/// - [x2] right edge of the rectangle
/// - [y2] bottom edge of the rectangle
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

/// Mirror the image around the vertical or horizontal axis.
///
/// - [image] the image to mirror in place
/// - [useVerticalMirroringInsteadOfHorizontal] true to mirror around the vertical axis, false for the horizontal one
final MirrorImage = _MirrorImageWrapper();

class _ExtractFaceImageWrapper {

  late int Function(int, Pointer<PointF>, int, int, Pointer<Uint32>, Pointer<PointF>) _func;

  _ExtractFaceImageWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<PointF>, Int32, Int32, Pointer<Uint32>, Pointer<PointF>)>>('FSDK_ExtractFaceImage').asFunction();
  }

  ExtractedFace call(Image image, FacialFeatures facialFeatures, int width, int height, {Image? extractedFaceImage, FacialFeatures? resizedFeatures}) {
    extractedFaceImage ??= Image._allocate();
    resizedFeatures ??= FacialFeatures.allocate();
    _checkErrorCode(_func(image.handle, facialFeatures.pointer, width, height, extractedFaceImage.pointer, resizedFeatures.pointer), 'ExtractFaceImage');
    return ExtractedFace(extractedFaceImage, resizedFeatures);
  }
}

/// Extract the part of the image containing the face, resized to `width` x `height`.
///
/// - [image] the image to operate on
/// - [facialFeatures] the key points locating the face in [image]
/// - [width] width of the extracted image
/// - [height] height of the extracted image
/// - [extractedFaceImage] optional instance to fill and return; reusing one across calls skips an allocation
/// - [resizedFeatures] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Get the face template of a single face.
///
/// - [image] the image to operate on
/// - [faceTemplate] optional instance to fill and return; reusing one across calls skips an allocation
final GetFaceTemplate = _GetFaceTemplateWrapper();

class _GetFaceTemplateInRegionWrapper {

  late int Function(int, Pointer<_Face>, Pointer<Uint8>) _func;

  _GetFaceTemplateInRegionWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<_Face>, Pointer<Uint8>)>>('FSDK_GetFaceTemplateInRegion').asFunction();
  }

  FaceTemplate call(Image image, Face face, {FaceTemplate? faceTemplate}) {
    faceTemplate ??= FaceTemplate._allocate();
    _checkErrorCode(_func(image.handle, face.pointer, faceTemplate.pointer), 'GetFaceTemplateInRegion');
    return faceTemplate;
  }
}

/// Get the face template of a given face.
///
/// - [image] the image to operate on
/// - [face] the face region to work within
/// - [faceTemplate] optional instance to fill and return; reusing one across calls skips an allocation
final GetFaceTemplateInRegion = _GetFaceTemplateInRegionWrapper();

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

/// Get the similarity score between two face templates.
///
/// - [faceTemplate1] the first template to compare
/// - [faceTemplate2] the second template to compare
final MatchFaces = _MatchFacesWrapper();

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

/// Create a new, empty tracker.
///
/// - [tracker] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Free the tracker. It becomes invalid.
///
/// - [tracker] the tracker to release
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

/// Clear the tracker's memory.
///
/// - [tracker] the tracker to operate on
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

/// Set a tracker parameter.
///
/// - [tracker] the tracker to operate on
/// - [parameterName] the name of the parameter
/// - [parameterValue] the value to set
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

/// Set several tracker parameters at once. Returns the position of the first syntax error.
///
/// - [tracker] the tracker to operate on
/// - [parameters] the parameters to set, as name/value pairs
final SetTrackerMultipleParameters = _SetTrackerMultipleParametersWrapper();

class _GetTrackerParameterWrapper {

  late int Function(int, Pointer<Utf8>, Pointer<Utf8>, int) _func;

  _GetTrackerParameterWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Utf8>, Pointer<Utf8>, Int64)>>('FSDK_GetTrackerParameter').asFunction();
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

/// Get a tracker parameter.
///
/// - [tracker] the tracker to operate on
/// - [parameterName] the name of the parameter
/// - [maxSizeInBytes] size of the buffer allocated for the result
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

/// Feed a frame to the tracker, returning the ids detected in it.
///
/// - [tracker] the tracker to operate on
/// - [cameraIdx] the camera index the frame was fed with
/// - [image] the image to operate on
/// - [ids] optional instance to fill and return; reusing one across calls skips an allocation
/// - [maxSize] the most results to return
final FeedFrame = _FeedFrameWrapper();

class _GetTrackerEyesWrapper {

  late int Function(int, int, int, Pointer<PointF>) _func;

  _GetTrackerEyesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Int64, Pointer<PointF>)>>('FSDK_GetTrackerEyes').asFunction();
  }

  FacialFeatures call(Tracker tracker, int cameraIdx, int id, {FacialFeatures? facialFeatures}) {
    facialFeatures ??= FacialFeatures._allocate();
    _checkErrorCode(_func(tracker.handle, cameraIdx, id, facialFeatures.pointer), 'GetTrackerEyes');
    return facialFeatures;
  }
}

/// Get the eye centers detected for an id.
///
/// Only the [FacialFeatures.LeftEye] and [FacialFeatures.RightEye] entries are
/// written; the rest of the returned object keeps whatever it held before.
///
/// - [tracker] the tracker to operate on
/// - [cameraIdx] the camera index the frame was fed with
/// - [id] the tracker id identifying a person
/// - [facialFeatures] optional instance to fill and return; reusing one across calls skips an allocation
final GetTrackerEyes = _GetTrackerEyesWrapper();

class _GetTrackerFacialFeaturesWrapper {

  late int Function(int, int, int, Pointer<PointF>) _func;

  _GetTrackerFacialFeaturesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Int64, Int64, Pointer<PointF>)>>('FSDK_GetTrackerFacialFeatures').asFunction();
  }

  FacialFeatures call(Tracker tracker, int cameraIdx, int id, {FacialFeatures? facialFeatures}) {
    facialFeatures ??= FacialFeatures._allocate();
    _checkErrorCode(_func(tracker.handle, cameraIdx, id, facialFeatures.pointer), 'GetTrackerFacialFeatures');
    return facialFeatures;
  }
}

/// Get the facial key points detected for an id.
///
/// - [tracker] the tracker to operate on
/// - [cameraIdx] the camera index the frame was fed with
/// - [id] the tracker id identifying a person
/// - [facialFeatures] optional instance to fill and return; reusing one across calls skips an allocation
final GetTrackerFacialFeatures = _GetTrackerFacialFeaturesWrapper();

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

/// Get the face detected for an id.
///
/// - [tracker] the tracker to operate on
/// - [cameraIdx] the camera index the frame was fed with
/// - [id] the tracker id identifying a person
/// - [face] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Prevent an id from being reassigned or purged.
///
/// - [tracker] the tracker to operate on
/// - [id] the tracker id identifying a person
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

/// Release a lock previously taken with `LockID`.
///
/// - [tracker] the tracker to operate on
/// - [id] the tracker id identifying a person
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

/// Remove an id from the tracker's memory.
///
/// - [tracker] the tracker to operate on
/// - [id] the tracker id identifying a person
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

/// Set the name associated with an id.
///
/// - [tracker] the tracker to operate on
/// - [id] the tracker id identifying a person
/// - [name] the name to associate with the id
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

/// Get the name associated with an id.
///
/// - [tracker] the tracker to operate on
/// - [id] the tracker id identifying a person
/// - [maxSizeInBytes] size of the buffer allocated for the result
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

/// Get every name associated with an id.
///
/// - [tracker] the tracker to operate on
/// - [id] the tracker id identifying a person
/// - [maxSizeInBytes] size of the buffer allocated for the result
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

/// Get the id this id was reassigned to, if any.
///
/// - [tracker] the tracker to operate on
/// - [id] the tracker id identifying a person
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

/// Get the number of ids considered similar to this one.
///
/// - [tracker] the tracker to operate on
/// - [id] the tracker id identifying a person
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

/// Get the ids considered similar to this one.
///
/// - [tracker] the tracker to operate on
/// - [id] the tracker id identifying a person
/// - [similarIDList] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Save tracker memory to a file.
///
/// - [tracker] the tracker to operate on
/// - [fileName] path to the file
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

/// Load tracker memory from a file.
///
/// - [fileName] path to the file
/// - [tracker] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Get the size in bytes needed to store the tracker's memory.
///
/// - [tracker] the tracker to operate on
final GetTrackerMemoryBufferSize = _GetTrackerMemoryBufferSizeWrapper();

class _SaveTrackerMemoryToBufferWrapper {

  late int Function(int, Pointer<Uint8>, int) _func;

  _SaveTrackerMemoryToBufferWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<Uint8>, Int64)>>('FSDK_SaveTrackerMemoryToBuffer').asFunction();
  }

  DataBuffer call(Tracker tracker, {DataBuffer? buffer}) {
    buffer ??= DataBuffer._allocate(tracker.bufferSize);
    _checkErrorCode(_func(tracker.handle, buffer.pointer, buffer.capacity), 'SaveTrackerMemoryToBuffer');
    return buffer;
  }
}

/// Save tracker memory to a buffer.
///
/// - [tracker] the tracker to operate on
/// - [buffer] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Load tracker memory from a buffer.
///
/// - [buffer] the tracker memory to load
/// - [tracker] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Get facial attribute values (angles, liveness, ...) for an id.
///
/// - [tracker] the tracker to operate on
/// - [cameraIdx] the camera index the frame was fed with
/// - [id] the tracker id identifying a person
/// - [attributeName] the attribute to query, such as `Gender` or `Liveness`
/// - [maxSizeInBytes] size of the buffer allocated for the result
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

/// Get the number of ids held by the tracker.
///
/// - [tracker] the tracker to operate on
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

/// Get every id held by the tracker.
///
/// - [tracker] the tracker to operate on
/// - [ids] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Get the number of face ids stored for an id.
///
/// - [tracker] the tracker to operate on
/// - [id] the tracker id identifying a person
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

/// Get the face ids stored for an id.
///
/// - [tracker] the tracker to operate on
/// - [id] the tracker id identifying a person
/// - [faceIDs] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Get the id a face id belongs to.
///
/// - [tracker] the tracker to operate on
/// - [faceID] the face id identifying one stored face of a person
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

/// Get the face template stored for a face id.
///
/// - [tracker] the tracker to operate on
/// - [faceID] the face id identifying one stored face of a person
/// - [faceTemplate] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Get the face image stored for a face id.
///
/// - [tracker] the tracker to operate on
/// - [faceID] the face id identifying one stored face of a person
/// - [image] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Store a face image for a face id.
///
/// - [tracker] the tracker to operate on
/// - [faceID] the face id identifying one stored face of a person
/// - [faceImage] the image to store
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

/// Delete the face image stored for a face id.
///
/// - [tracker] the tracker to operate on
/// - [faceID] the face id identifying one stored face of a person
final DeleteTrackerFaceImage = _DeleteTrackerFaceImageWrapper();

/// The id and face id created for a face template.
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

/// Create a new id from a face template.
///
/// - [tracker] the tracker to operate on
/// - [faceTemplate] the face template to use
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

/// Add a face template to an existing id.
///
/// - [tracker] the tracker to operate on
/// - [id] the tracker id identifying a person
/// - [faceTemplate] the face template to use
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

/// Delete a face from the tracker's memory.
///
/// - [tracker] the tracker to operate on
/// - [faceID] the face id identifying one stored face of a person
final DeleteTrackerFace = _DeleteTrackerFaceWrapper();

/// The best matching tracker id and its similarity score.
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
    _checkErrorCode(_func(tracker.handle, faceTemplate.pointer, threshold, idSimilarities.pointer, idSimilarities._lengthPointer, sizeOf<IDSimilarity>() * idSimilarities.capacity), 'TrackerMatchFaces');
    return idSimilarities;
  }
}

/// Match a template against the tracker's memory.
///
/// - [tracker] the tracker to operate on
/// - [faceTemplate] the face template to use
/// - [threshold] the lowest similarity worth returning
/// - [idSimilarities] optional instance to fill and return; reusing one across calls skips an allocation
/// - [maxCount] the most results to return
final TrackerMatchFaces = _TrackerMatchFacesWrapper();

class _DetectFacialAttributeUsingFeaturesWrapper {

  late int Function(int, Pointer<PointF>, Pointer<Utf8>, Pointer<Utf8>, int) _func;

  _DetectFacialAttributeUsingFeaturesWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<PointF>, Pointer<Utf8>, Pointer<Utf8>, Int64)>>('FSDK_DetectFacialAttributeUsingFeatures').asFunction();
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

/// Detect facial attribute values using facial key points.
///
/// - [image] the image to operate on
/// - [facialFeatures] the key points of the face to inspect
/// - [attributeName] the attribute to query, such as `Gender` or `Liveness`
/// - [maxSizeInBytes] size of the buffer allocated for the result
final DetectFacialAttributeUsingFeatures = _DetectFacialAttributeUsingFeaturesWrapper();

class _DetectFacialAttributeUsingFaceWrapper {

  late int Function(int, Pointer<_Face>, Pointer<Utf8>, Pointer<Utf8>, int) _func;

  _DetectFacialAttributeUsingFaceWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Uint32, Pointer<_Face>, Pointer<Utf8>, Pointer<Utf8>, Int64)>>('FSDK_DetectFacialAttributeUsingFace').asFunction();
  }

  String call(Image image, Face face, String attributeName, {int maxSizeInBytes = 256}) {
    final var1 = attributeName.toNativeUtf8();
    final var2 = malloc.allocate<Utf8>(maxSizeInBytes);
    try {
      _checkErrorCode(_func(image.handle, face.pointer, var1, var2, maxSizeInBytes), 'DetectFacialAttributeUsingFace');
      return var2.toDartString();
    } finally {
      malloc.free(var2);
      malloc.free(var1);
    }
  }
}

/// Detect facial attribute values using a detected face.
///
/// - [image] the image to operate on
/// - [face] the face region to work within
/// - [attributeName] the attribute to query, such as 'Gender' or 'Liveness'
/// - [maxSizeInBytes] size of the buffer allocated for the result
final DetectFacialAttributeUsingFace = _DetectFacialAttributeUsingFaceWrapper();

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

/// Get the confidence of `value` within a `key=value;` attribute string.
///
/// - [attributeValues] a `key=value;` string as returned by the attribute functions
/// - [value] the value whose confidence to read
final GetValueConfidence = _GetValueConfidenceWrapper();

class _SetHTTPProxyWrapper {

  late int Function(Pointer<Utf8>, int, Pointer<Utf8>, Pointer<Utf8>) _func;

  _SetHTTPProxyWrapper() {
    _func = _nativeLib.lookup<NativeFunction<Int32 Function(Pointer<Utf8>, Uint16, Pointer<Utf8>, Pointer<Utf8>)>>('FSDK_SetHTTPProxy').asFunction();
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

/// Set the HTTP proxy used for IP cameras.
///
/// - [serverNameOrIPAddress] the proxy host
/// - [port] the proxy port
/// - [userName] user name for the proxy, empty if it needs none
/// - [password] password for the camera, empty if it needs none
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

/// Open an IP video camera.
///
/// - [compressionType] the stream compression used by the camera
/// - [url] the camera stream address
/// - [username] user name for the camera, empty if it needs none
/// - [password] password for the camera, empty if it needs none
/// - [timeoutSeconds] how long to wait for the camera before failing
/// - [cameraHandle] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Close the camera. It becomes invalid.
///
/// - [cameraHandle] the camera to close
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

/// Grab a frame from the camera.
///
/// - [cameraHandle] the camera to operate on
/// - [image] optional instance to fill and return; reusing one across calls skips an allocation
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

/// Initialize the capturing subsystem.
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

/// Finalize the capturing subsystem.
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

/// Set a global SDK parameter.
///
/// - [parameterName] the name of the parameter
/// - [parameterValue] the value to set
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

/// Set several global SDK parameters at once.
///
/// - [parameters] the parameters to set, as name/value pairs
final SetParameters = _SetParametersWrapper();

/// The writable directory the liveness data files are extracted into.
Future<Directory> getCacheDirectory() async {
  final directory = await getApplicationCacheDirectory();
  return directory;
}

/// Whether a directory exists at [path].
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
    'data/pipelines/persephone.json',
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

/// Extract the bundled iBeta liveness data files and return the directory holding
/// them. Pass that directory to the `LivenessModel` parameter as
/// `external:dataDir=<path>/` before feeding any frames. Files already extracted
/// are left alone, so calling this on every launch is cheap.
Future<String> PrepareData() async {
  final dataDirectory = await _copyAssets();
  return dataDirectory;
}
