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
    required this.userId,
    required this.roleId,
    required this.token,
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

  @HiveField(5)
  String userId;

  @HiveField(6)
  String roleId;

  @HiveField(7)
  String token;

  @override
  String toString() {
    return '''
User{role: $role, sector: $sector, name: $name, phone: $phone, device: $device, userId: $userId, roleId: $roleId, token: $token}
  ''';
  }
}
