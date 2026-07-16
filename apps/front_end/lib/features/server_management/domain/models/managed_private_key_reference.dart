import 'package:dart_mappable/dart_mappable.dart';

part 'managed_private_key_reference.mapper.dart';

@MappableClass()
class ManagedPrivateKeyReference with ManagedPrivateKeyReferenceMappable {
  const ManagedPrivateKeyReference({required this.id, required this.displayName});

  final String id;
  final String displayName;
}
