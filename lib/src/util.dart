import 'package:dbus/dbus.dart';

extension DbusProperties on Map<String, DBusValue> {
  T? get<T>(String key) => this[key]?.toNative() as T?;
}

extension OrNull on double? {
  double? orNullIf(double value) => this != value ? this : null;
}

extension Timestamp on DBusValue {
  DateTime? toTimestamp() {
    if (signature != DBusSignature('(tt)')) return null;
    final sec = (this as DBusStruct).children.first as DBusUint64;
    final usec = (this as DBusStruct).children.last as DBusUint64;
    return DateTime.fromMicrosecondsSinceEpoch(
        sec.value * 1000000 + usec.value);
  }
}
