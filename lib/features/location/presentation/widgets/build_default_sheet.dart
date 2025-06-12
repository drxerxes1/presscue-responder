import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_text.dart';
import 'package:presscue_patroller/core/services/base_url_provider.dart';
import 'package:presscue_patroller/core/services/socket/private_websocket_channel.dart';
import 'package:presscue_patroller/features/location/data/event_service_provider.dart';
import 'package:presscue_patroller/features/location/presentation/providers/incident_provider.dart';
import 'package:vibration/vibration.dart';
import '../../data/respond_emergency.dart';
import '../providers/sheet_provider.dart';

class BuildDefaultSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const BuildDefaultSheet({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  ConsumerState<BuildDefaultSheet> createState() => _BuildDefaultSheetState();
}

class _BuildDefaultSheetState extends ConsumerState<BuildDefaultSheet> {
  final player = AudioPlayer();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final hasPlayedSound = ref.watch(hasPlayedSoundProvider);
    final connectionStatus = ref.watch(webSocketConnectionStatusProvider);
    final event = ref.watch(eventServiceProvider);

    final eventName = event?.eventName;
    final eventData = event?.data;

    final String message = eventData?['message'] ?? "No message provided";
    var content = eventData?['content'] ?? "No content available";

    if (eventName == 'patroller_dispatched' && !hasPlayedSound) {
      playSound();
      Future.microtask(() {
        ref.read(hasPlayedSoundProvider.notifier).state = true;
      });
    }

    if (eventName == 'patroller_dispatched') {
      final int incidentId = event?.data['id'];
      print('Incident ID: $incidentId');
      Future.microtask(() {
        ref.read(incidentProvider.notifier).setIncidentId(incidentId);
      });
    }

    return ListView(
      controller: widget.scrollController,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (eventName == 'connection_established' &&
            connectionStatus == WebSocketConnectionStatus.connected) ...[
          Text(
            "$message",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            textAlign: TextAlign.center,
            style: AppText.body2,
          ),
        ] else if (eventName == 'patroller_dispatched') ...[
          Text(
            "🚨  $message",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() {
                      _isLoading = true;
                    });

                    final incidentId = ref.watch(incidentProvider);
                    final String url = await BaseUrlProvider.buildUri(
                        'incident/$incidentId/respond');

                    await respondEmergency(ref, url);

                    setState(() {
                      _isLoading = false;
                    });
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text(
                    "Respond",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ] else if (eventName != 'connection_established') ...[
          Text(
            "⚠️  $message",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            textAlign: TextAlign.center,
            style: AppText.body2,
          ),
        ]
      ],
    );
  }

  Future<void> playSound() async {
    String audioPath = "audio/emergency-alarm.mp3";
    await player.play(AssetSource(audioPath));

    Duration position = Duration(seconds: 3);
    player.seek(position);

    if (await Vibration.hasVibrator()) {
      Timer.periodic(Duration(milliseconds: 2000), (timer) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000]);

        if (timer.tick >= 2) {
          timer.cancel();
        }
      });
    }
  }
}
