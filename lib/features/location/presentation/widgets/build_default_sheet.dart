import 'dart:async';
import 'dart:convert';
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
  Timer? _denyTimer;
  bool hasResponded = false;
  final privateService = PrivateWebSocketService();
  bool _isDisposed = false;

  @override
  void dispose() {
    _denyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPlayedSound = ref.watch(hasPlayedSoundProvider);
    final connectionStatus = ref.watch(webSocketConnectionStatusProvider);
    final event = ref.watch(eventServiceProvider);

    final eventName = event?.eventName;

    if (eventName == 'patroller_dispatched' && !hasPlayedSound) {
      playSound();
      Future.microtask(() {
        ref.read(hasPlayedSoundProvider.notifier).state = true;
      });
    }

    if (eventName == 'patroller_dispatched') {
      try {
        final rawData = event?.data;
        final decodedData = rawData is String ? jsonDecode(rawData) : rawData;
        final incidentId = decodedData?['incident']?['id'];

        if (incidentId is int) {
          Future.microtask(() {
            ref.read(incidentProvider.notifier).setIncidentId(incidentId);
          });

          if (_denyTimer == null || !_denyTimer!.isActive) {
            _denyTimer = Timer(const Duration(seconds: 10), () async {
              if (!hasResponded) {
                final url = await BaseUrlProvider.buildUri(
                  'incident/$incidentId/deny',
                );
                try {
                  await respondEmergency(ref, url);

                  ref.read(eventServiceProvider.notifier).updateEvent(
                    'connection_established',
                    {},
                  );
                  ref.read(hasPlayedSoundProvider.notifier).state = false;

                  debugPrint('[BuildDefaultSheet] Auto-denied after 10s');
                } catch (e) {
                  debugPrint('[BuildDefaultSheet] Auto-deny failed: $e');
                }
              }
            });
          }

          debugPrint('Incident ID: $incidentId');
        } else {
          debugPrint('[BuildDefaultSheet] ID is not an int or missing.');
        }
      } catch (e) {
        debugPrint('[BuildDefaultSheet] Failed to decode event data: $e');
      }
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
            "Connection Established",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You are connected to the server. On standby for updates.',
            textAlign: TextAlign.center,
            style: AppText.body2,
          ),
        ] else if (eventName == 'patroller_dispatched') ...[
          Text(
            "🚨  Emergency !!",
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

                    hasResponded = true;
                    _denyTimer?.cancel();

                    final incidentId = ref.watch(incidentProvider);
                    final String url = await BaseUrlProvider.buildUri(
                        'incident/$incidentId/respond');

                    await respondEmergency(ref, url);

                    privateService.connect(
                      onStatusChanged: (status) {
                        if (!_isDisposed && mounted) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              ref
                                  .read(webSocketConnectionStatusProvider
                                      .notifier)
                                  .state = status;
                            }
                          });
                        }
                      },
                      channelType: WebSocketChannelType.private,
                      customChannelPrefix: 'private-incident.$incidentId',
                    );

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
            "⚠️  Not Connected",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Not connected to server.",
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
