// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/services/whatsapp_call_service.dart';
import 'package:AstrowayCustomer/utils/images.dart';

/**
 * 🚀 WHATSAPP-LIKE: Call Screen UI
 * Clean, modern interface similar to WhatsApp calls
 */
class WhatsAppCallScreen extends StatefulWidget {
  final String channelName;
  final String token;
  final String appId;
  final String astrologerName;
  final String? astrologerProfile;
  final String callType; // 'audio' or 'video'
  final bool isInitiator;

  WhatsAppCallScreen({
    super.key,
    required this.channelName,
    required this.token,
    required this.appId,
    required this.astrologerName,
    this.astrologerProfile,
    required this.callType,
    required this.isInitiator,
  });

  @override
  State<WhatsAppCallScreen> createState() => _WhatsAppCallScreenState();
}

class _WhatsAppCallScreenState extends State<WhatsAppCallScreen> {
  final WhatsAppCallService callService = WhatsAppCallService();
  Timer? _callTimer;
  int _callDuration = 0;
  
  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (callService.isCallConnected.value) {
        setState(() {
          _callDuration++;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.callType == 'video' ? Colors.black : const Color(0xFF0C1317),
      body: SafeArea(
        child: widget.callType == 'video' ? _buildVideoCallUI() : _buildAudioCallUI(),
      ),
    );
  }

  Widget _buildVideoCallUI() {
    return Stack(
      children: [
        // Remote video (full screen)
        Obx(() => callService.remoteUid != null
            ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: callService.agoraEngine!,
                  canvas: VideoCanvas(uid: callService.remoteUid),
                  connection: RtcConnection(channelId: widget.channelName),
                ),
              )
            : _buildWaitingUI()),

        // Local video (small window)
        Positioned(
          top: 50,
          right: 20,
          child: Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Obx(() => callService.isVideoEnabled.value
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: callService.agoraEngine!,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      child: const Icon(
                        Icons.videocam_off,
                        color: Colors.white,
                        size: 40,
                      ),
                    )),
            ),
          ),
        ),

        // Call controls
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: _buildCallControls(),
        ),

        // Call info
        Positioned(
          top: 50,
          left: 20,
          child: _buildCallInfo(),
        ),
      ],
    );
  }

  Widget _buildAudioCallUI() {
    return Column(
      children: [
        const SizedBox(height: 80),
        
        // Profile picture
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 3),
          ),
          child: ClipOval(
            child: widget.astrologerProfile != null
                ? CachedNetworkImage(
                    imageUrl: widget.astrologerProfile!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(Images.deafultUser),
                    errorWidget: (context, url, error) => Image.asset(Images.deafultUser),
                  )
                : Image.asset(Images.deafultUser, fit: BoxFit.cover),
          ),
        ),

        const SizedBox(height: 30),

        // Name
        Text(
          widget.astrologerName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 10),

        // Call status
        Obx(() => Text(
          callService.isCallConnected.value 
              ? _formatDuration(_callDuration)
              : widget.isInitiator ? 'Calling...' : 'Incoming call',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        )),

        const Spacer(),

        // Call controls
        _buildCallControls(),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildWaitingUI() {
    return Container(
      color: const Color(0xFF0C1317),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 3),
              ),
              child: ClipOval(
                child: widget.astrologerProfile != null
                    ? CachedNetworkImage(
                        imageUrl: widget.astrologerProfile!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image.asset(Images.deafultUser),
                        errorWidget: (context, url, error) => Image.asset(Images.deafultUser),
                      )
                    : Image.asset(Images.deafultUser, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.astrologerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Connecting...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            'End-to-end encrypted',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          Obx(() => _buildControlButton(
            icon: callService.isMuted.value ? Icons.mic_off : Icons.mic,
            isActive: !callService.isMuted.value,
            onTap: callService.toggleMute,
          )),

          // Video button (only for video calls)
          if (widget.callType == 'video')
            Obx(() => _buildControlButton(
              icon: callService.isVideoEnabled.value ? Icons.videocam : Icons.videocam_off,
              isActive: callService.isVideoEnabled.value,
              onTap: callService.toggleVideo,
            )),

          // Speaker button (only for audio calls)
          if (widget.callType == 'audio')
            Obx(() => _buildControlButton(
              icon: callService.isSpeakerOn.value ? Icons.volume_up : Icons.volume_down,
              isActive: callService.isSpeakerOn.value,
              onTap: callService.toggleSpeaker,
            )),

          // Camera switch (only for video calls)
          if (widget.callType == 'video')
            _buildControlButton(
              icon: Icons.cameraswitch,
              isActive: true,
              onTap: callService.switchCamera,
            ),

          // End call button
          _buildControlButton(
            icon: Icons.call_end,
            isActive: false,
            backgroundColor: Colors.red,
            onTap: () async {
              await callService.endCall();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    Color? backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isActive ? Colors.white24 : Colors.white12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: backgroundColor == Colors.red ? Colors.white : (isActive ? Colors.white : Colors.white60),
          size: 28,
        ),
      ),
    );
  }
}
