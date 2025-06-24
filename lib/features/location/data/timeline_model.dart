import 'package:intl/intl.dart';

class TimelineEvent {
  final String header;
  final String description;
  final String time;

  TimelineEvent({
    required this.header,
    required this.description,
    required this.time,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at']?.toString() ?? '';
    final DateTime createdAtUtc = DateTime.tryParse(createdAtRaw)?.toUtc() ?? DateTime.now().toUtc();
    final DateTime createdAtLocal = createdAtUtc.toLocal();
    final String formattedTime = DateFormat.jm().format(createdAtLocal);

    return TimelineEvent(
      header: json['header']?.toString() ?? 'No header',
      description: json['description']?.toString() ?? 'No description',
      time: formattedTime,
    );
  }
}
