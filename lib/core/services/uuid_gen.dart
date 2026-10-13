import 'package:uuid/uuid.dart';

class UuidGen {
  const UuidGen([this._uuid = const Uuid()]);

  final Uuid _uuid;

  String newId() => _uuid.v4();
}
