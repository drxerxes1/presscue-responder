import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  User({
    required this.sector_id,
    required this.name,
    required this.phone,
    required this.device,
    required this.userId,
    required this.category_id,
    required this.token,
  });

  @HiveField(0)
  String sector_id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String device;

  @HiveField(4)
  String userId;

  @HiveField(5)
  String category_id;

  @HiveField(6)
  String token;

  @override
  String toString() {
    return '''
User{sector_id: $sector_id, name: $name, phone: $phone, device: $device, userId: $userId, category_id: $category_id, token: $token}
  ''';
  }
}
