import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_text.dart';
import 'package:presscue_patroller/core/services/socket/private_websocket_channel.dart';
import 'package:presscue_patroller/features/location/data/event_service_provider.dart';
import 'package:presscue_patroller/features/location/presentation/providers/citizen_location_provider.dart';
import 'package:presscue_patroller/features/location/presentation/providers/incident_provider.dart';
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
  final privateService = PrivateWebSocketService();
  bool _isDisposed = false;
  int? _lastTimelineId;
  bool _isWebSocketConnected = false;
  Map<String, dynamic>? _latestTimeline;
  List<String>? _latestKeywords;
  late final ProviderSubscription<Map<String, dynamic>?> _timelineSub;
  late final ProviderSubscription<List<String>?> _keywordsSub;

  @override
  void initState() {
    super.initState();

    _latestTimeline = ref.read(timelineDataProvider);
    _latestKeywords = ref.read(keywordsDataProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timelineDataProvider.notifier).state = _latestTimeline;
      ref.read(keywordsDataProvider.notifier).state = _latestKeywords;

      _tryPopulate();
    });

    _timelineSub = ref.listenManual<Map<String, dynamic>?>(
      timelineDataProvider,
      (prev, next) {
        if (!mounted) return;
        _latestTimeline = next;
        _tryPopulate();
      },
    );

    _keywordsSub = ref.listenManual<List<String>?>(
      keywordsDataProvider,
      (prev, next) {
        if (!mounted) return;
        _latestKeywords = next;
        _tryPopulate();
      },
    );
  }

  void _tryPopulate() {
    if (_latestTimeline != null && _latestKeywords != null && mounted) {
      _populateFromResponse(_latestTimeline!, _latestKeywords!);
    } else {}
  }

  void _handleWebSocketEvent(String eventName, dynamic data) {
    if (_isDisposed) return;
    print('Event Name: $eventName');
    return ref.read(eventServiceProvider.notifier).updateEvent(eventName, data);
  }

  @override
  void dispose() {
    _timelineSub.close();
    _keywordsSub.close();
    privateService.disconnect();
    _isDisposed = true;
    super.dispose();
  }

  void _populateFromResponse(
      Map<String, dynamic> data, List<String> keywordsData) {
    final newCitizenName =
        data['citizen']?['name']?.toString() ?? "Unknown Citizen";
    final newCitizenPhone =
        data['citizen']?['phone']?.toString() ?? "No phone available";
    final newAddress =
        data['location']?['address']?.toString() ?? "No address available";
    final List<String> newCategoryTitles = keywordsData;

    final newEvents = (data['timelines'] as List<dynamic>?)
            ?.map((timeline) =>
                TimelineEvent.fromJson(timeline as Map<String, dynamic>))
            .toList() ??
        [];

    final latestTimeline = (data['timelines'] as List<dynamic>?)?.lastOrNull;
    final location = latestTimeline?['location'];
    final double? lat = location?['latitude']?.toDouble();
    final double? lng = location?['longitude']?.toDouble();

    if (lat != null && lng != null) {
      ref.read(citizenLocationProvider.notifier).updateLocation(lat, lng);
      print('Location updated: ($lat, $lng)');
    } else {
      print('No valid location found in latest timeline');
    }

    if (!mounted) return;

    setState(() {
      _citizenName = newCitizenName;
      _citizenPhone = newCitizenPhone;
      _citizenAddress = newAddress;
      _categoryTitles = newCategoryTitles;
      _events = newEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    final incidentId = ref.watch(incidentProvider);
    if (!_isWebSocketConnected && incidentId != null) {
      _isWebSocketConnected = true;
      privateService.connect(
        onStatusChanged: (status) {
          if (!_isDisposed && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(webSocketConnectionStatusProvider.notifier).state =
                  status;
            });
          }
        },
        channelType: WebSocketChannelType.private,
        customChannelPrefix: 'private-incident.$incidentId',
        onEventReceived: _handleWebSocketEvent,
      );
    }

    // Handle incoming WebSocket events (new_timeline)
    ref.listen(eventServiceProvider, (previous, next) {
      if (!_isDisposed && next != null && next.eventName == 'new_timeline') {
        final rawData = next.data;
        try {
          final parsedOuter = rawData is String ? jsonDecode(rawData) : rawData;
          final parsed = parsedOuter is Map && parsedOuter['timeline'] == null
              ? jsonDecode(parsedOuter['data'])
              : parsedOuter;

          final timelineJson = parsed['timeline'];
          if (timelineJson != null) {
            final int timelineId = timelineJson['id'];

            if (_lastTimelineId == timelineId) return;
            _lastTimelineId = timelineId;

            final newTimelineEvent =
                TimelineEvent.fromJson(timelineJson as Map<String, dynamic>);

            // final incidentJson = timelineJson['incident'];
            // final categoryJson = incidentJson?['category'];

            // final List<String> newCategoryTitles = categoryJson != null
            //     ? [categoryJson['title']?.toString() ?? 'Unknown']
            //     : [];

            // final newCitizenName =
            //     incidentJson?['citizen']?['name']?.toString() ??
            //         "Unknown Citizen";
            // final newCitizenPhone =
            //     incidentJson?['citizen']?['phone']?.toString() ?? "No phone";
            final newAddress =
                timelineJson['location']?['address']?.toString() ??
                    'No address available';

            final location = timelineJson['location'];
            final double? lat = location?['latitude']?.toDouble();
            final double? lng = location?['longitude']?.toDouble();

            if (lat != null && lng != null) {
              ref
                  .read(citizenLocationProvider.notifier)
                  .updateLocation(lat, lng);
              print('Location updated: ($lat, $lng)');
            } else {
              print('No valid location found in latest timeline');
            }

            if (mounted) {
              setState(() {
                _events.add(newTimelineEvent);
                // _citizenName = newCitizenName;
                // _citizenPhone = newCitizenPhone;
                _citizenAddress = newAddress;
                // _categoryTitles = newCategoryTitles;
              });
            }
          }
        } catch (e, stack) {
          debugPrint('Error decoding new_timeline event: $e');
          debugPrintStack(stackTrace: stack);
        }
      }
    });

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
