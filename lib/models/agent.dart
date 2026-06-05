import 'package:uuid/uuid.dart';

class Agent {
  final String id;
  String name;

  final String identity;

  Agent({String? id, required this.name, required this.identity})
    : id = id?.isNotEmpty == true ? id! : const Uuid().v4();
}
