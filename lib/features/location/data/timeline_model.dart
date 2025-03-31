class TimelineEvent {
  final String header;
  final String description;
  final String time;

  TimelineEvent({required this.header, required this.description, required this.time});

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      header: json['header']?.toString() ?? 'No description',
      description: json['description']?.toString() ?? 'No description',
      time: json['created_at']?.toString() ?? 'No time',
    );
  }
}
