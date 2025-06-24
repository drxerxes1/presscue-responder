import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_text.dart';
import 'package:presscue_patroller/features/location/data/event_service_provider.dart';
import 'package:presscue_patroller/features/location/presentation/providers/location_provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../data/timeline_model.dart';

class BuildTimelineSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const BuildTimelineSheet({Key? key, required this.scrollController})
      : super(key: key);

  @override
  _BuildTimelineSheetState createState() => _BuildTimelineSheetState();
}

class _BuildTimelineSheetState extends ConsumerState<BuildTimelineSheet> {
  List<TimelineEvent> _events = [];
  String _citizenName = "Unknown Citizen";
  String _citizenPhone = "No phone available";
  String _citizenAddress = "No address available";
  List<String> _categoryTitles = [];

  @override
  void initState() {
    super.initState();
    final initialData = ref.read(timelineDataProvider);

    if (initialData != null) {
      _populateFromResponse(initialData);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _populateFromResponse(Map<String, dynamic> data) {
    final newCitizenName =
        data['citizen']?['name']?.toString() ?? "Unknown Citizen";
    final newCitizenPhone =
        data['citizen']?['phone']?.toString() ?? "No phone available";
    final List<String> newCategoryTitles = data['category'] != null
        ? [data['category']['title']?.toString() ?? "Unknown"]
        : [];

    final newEvents = (data['timelines'] as List<dynamic>?)
            ?.map((timeline) =>
                TimelineEvent.fromJson(timeline as Map<String, dynamic>))
            .toList() ??
        [];

    setState(() {
      _citizenName = newCitizenName;
      _citizenPhone = newCitizenPhone;
      _citizenAddress = "Unknown";
      _categoryTitles = newCategoryTitles;
      _events = newEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(eventServiceProvider);
    final eventName = event?.eventName;
    final rawData = event?.data;

    if (eventName == 'timeline_updated' && rawData != null) {
      final data = rawData is String ? rawData : rawData;
      try {
        final parsed = data is String ? event!.data : data;
        final parsedData = parsed is String ? null : parsed;

        if (parsedData != null) {
          final newCitizenName =
              parsedData['citizen']?['name']?.toString() ?? "Unknown Citizen";
          final newCitizenPhone = parsedData['citizen']?['phone']?.toString() ??
              "No phone available";
          final newCitizenAddress = parsedData['timelines']
                  ?.last['location']?['address']
                  ?.toString() ??
              "No address available";
          final List<String> newCategoryTitles =
              (parsedData['category'] != null)
                  ? [parsedData['category']['title']?.toString() ?? "Unknown"]
                  : [];

          final newEvents = (parsedData['timelines'] as List<dynamic>?)
                  ?.map((timeline) =>
                      TimelineEvent.fromJson(timeline as Map<String, dynamic>))
                  .toList() ??
              [];

          // Only update if changed
          if (!mounted) return Container();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _citizenName = newCitizenName;
              _citizenPhone = newCitizenPhone;
              _citizenAddress = newCitizenAddress;
              _categoryTitles = newCategoryTitles;
              _events = newEvents;
            });
          });
        }
      } catch (e) {
        debugPrint("Error parsing timeline update: $e");
      }
    }

    return ListView(
      controller: widget.scrollController,
      children: [
        _buildHandle(),
        _buildCitizenInfo(),
        _buildCategories(),
        _buildTimeline(),
      ],
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildCitizenInfo() {
    return _buildInfoRow("Emergency Confirmed", [
      _buildRow("Name", _citizenName),
      _buildRow("Phone", _citizenPhone),
      _buildRow("Address", _citizenAddress),
    ]);
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Text("$label: ", style: AppText.body2),
        Flexible(child: Text(value, style: AppText.body2)),
      ],
    );
  }

  Widget _buildCategories() {
    return _buildInfoRow("Keywords", [
      Text(
        _categoryTitles.isNotEmpty
            ? _categoryTitles.join(', ')
            : "Relevant keywords will be displayed here...",
        style: TextStyle(fontSize: 14, color: AppColors.mutedDark),
      ),
    ]);
  }

  Widget _buildInfoRow(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(title),
        ...children,
      ],
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.med)),
    );
  }

  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle("Timeline:"),
        ..._events.reversed.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          return _buildTimelineTile(index, event, index == 0);
        }).toList(),
      ],
    );
  }

  Widget _buildTimelineTile(int index, TimelineEvent event, bool isLatest) {
    return TimelineTile(
      isFirst: index == 0,
      isLast: index == _events.length - 1,
      indicatorStyle: IndicatorStyle(
        width: 15,
        color: isLatest ? Colors.green : Colors.grey,
        indicatorXY: 0.5,
      ),
      beforeLineStyle: LineStyle(color: Colors.grey, thickness: 2),
      endChild: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.header,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Text("Time: ${event.time}",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 3),
            Text(event.description, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
