import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_text.dart';
import 'package:presscue_patroller/core/services/base_url_provider.dart';
import 'package:presscue_patroller/features/location/presentation/providers/incident_provider.dart';
import 'package:vibration/vibration.dart';
import '../../data/respond_emergency.dart';
import '../providers/location_provider.dart';
import '../providers/sheet_provider.dart';

class BuildDefaultSheet extends StatefulWidget {
  final ScrollController scrollController;
  final WidgetRef ref;

  const BuildDefaultSheet({
    Key? key,
    required this.scrollController,
    required this.ref,
  }) : super(key: key);

  @override
  State<BuildDefaultSheet> createState() => _BuildDefaultSheetState();
}

class _BuildDefaultSheetState extends State<BuildDefaultSheet> {
  final player = AudioPlayer();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final serverResponse = widget.ref.watch(serverResponseProvider) ?? {};
    final hasPlayedSound = widget.ref.watch(hasPlayedSoundProvider);

    final String message = serverResponse['message'] ?? "Loading...";
    var content = serverResponse['content'] ?? "";
    final int statusCode = serverResponse['statusCode'] ?? 500;

    if (statusCode == 200 && !hasPlayedSound) {
      playSound();
      Future.microtask(() {
        widget.ref.read(hasPlayedSoundProvider.notifier).state = true;
      });
    }

    if (statusCode == 200) {
      final int incidentId = content['id'];
      print('Incident ID: $incidentId');
      Future.microtask(() {
        widget.ref.read(incidentProvider.notifier).setIncidentId(incidentId);
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
        if (statusCode == 204) ...[
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
        ] else if (statusCode == 200) ...[
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

                    final incidentId = widget.ref.watch(incidentProvider);
                    final String url = await BaseUrlProvider.buildUri(
                        'incident/$incidentId/respond');

                    // Await the emergency response call
                    await respondEmergency(widget.ref, url);

                    // Stop loading once request is completed
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
        ] else if (statusCode != 200) ...[
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

    if (await Vibration.hasVibrator() ?? false) {
      Timer.periodic(Duration(milliseconds: 2000), (timer) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000]);

        if (timer.tick >= 2) {
          timer.cancel();
        }
      });
    }
  }
}
