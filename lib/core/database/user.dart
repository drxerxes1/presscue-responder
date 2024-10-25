import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  User({
    required this.role,
    required this.sector,
    required this.name,
    required this.phone,
    required this.device,
  });

  @HiveField(0)
  String role;

  @HiveField(1)
  String sector;

  @HiveField(2)
  String name;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String device;

  @override
  String toString() {
    return '''
User{name: $role, email: $sector, password: $name, phone: $phone, device: $device}''';
  }
}
