// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/call/accept_call_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

/**
 * 📞 WHATSAPP-LIKE: Outgoing call screen
 * Shows "Calling..." while waiting for expert to accept
 */
class CallingScreen extends StatefulWidget {
  final String astrologerName;
  final int astrologerId;
  final String? astrologerProfile;
  final int callId;
  final String callType; // 'call' or 'Videocall'
  final String channelName;
  final String token;
  final String duration;

  CallingScreen({
    super.key,
    required this.astrologerName,
    required this.astrologerId,
    this.astrologerProfile,
    required this.callId,
    required this.callType,
    required this.channelName,
    required this.token,
    required this.duration,
  });

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> with SingleTickerProviderStateMixin {
  final CallController callController = Get.find<CallController>();
  late AnimationController _animationController;
  Timer? _pollTimer;
  bool _isCallAccepted = false;

  @override
  void initState() {
    super.initState();
    
    // Ringing animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Poll backend every 2 seconds to check if expert accepted
    _startPolling();
    
    print('📞 [CALLING SCREEN] Waiting for expert to accept...');
    print('📞 [CALLING SCREEN] Call ID: ${widget.callId}');
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_isCallAccepted) {
        timer.cancel();
        return;
      }
      
      await _checkCallStatus();
    });
  }

  Future<void> _checkCallStatus() async {
    try {
      // Check if call was accepted by expert
      final result = await callController.apiHelper.getCallStatus(widget.callId);
      
      if (result != null && result['status'] == 'Accepted') {
        print('✅ [CALLING SCREEN] Expert accepted! Joining call...');
        _isCallAccepted = true;
        _pollTimer?.cancel();
        
        // Navigate to actual call screen
        Get.off(() => AcceptCallScreen(
          astrologerName: widget.astrologerName,
          astrologerId: widget.astrologerId,
          astrologerProfile: widget.astrologerProfile,
          token: widget.token,
          callChannel: widget.channelName,
          callId: widget.callId,
          duration: widget.duration,
          isfromnotification: false,
        ));
      } else if (result != null && result['status'] == 'Rejected') {
        print('❌ [CALLING SCREEN] Expert rejected call');
        _pollTimer?.cancel();
        
        global.showToast(
          message: '${widget.astrologerName} is busy',
          textColor: global.textColor,
          bgColor: global.toastBackGoundColor,
        );
        
        Get.back();
      }
    } catch (e) {
      print('❌ [CALLING SCREEN] Error checking status: $e');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Cancel call when back button pressed
        await _cancelCall();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C1317),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Expert profile picture with ringing animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(
                          0.3 + (_animationController.value * 0.7),
                        ),
                        width: 3,
                      ),
                    ),
                    child: child,
                  );
                },
                child: ClipOval(
                  child: widget.astrologerProfile != null && widget.astrologerProfile!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: '${global.imgBaseurl}${widget.astrologerProfile}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset(Images.deafultUser),
                          errorWidget: (context, url, error) => Image.asset(Images.deafultUser),
                        )
                      : Image.asset(Images.deafultUser, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 40),

              // Expert name
              Text(
                widget.astrologerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 10),

              // Calling status with animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final dots = '.' * ((_animationController.value * 3).floor() + 1);
                  return Text(
                    'Calling$dots',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  );
                },
              ),

              const Spacer(),

              // Call type indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.callType == 'call' ? Icons.phone : Icons.videocam,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.callType == 'call' ? 'Voice Call' : 'Video Call',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // End call button
              GestureDetector(
                onTap: _cancelCall,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancelCall() async {
    print('❌ [CALLING SCREEN] Canceling call...');
    _pollTimer?.cancel();
    
    // Cancel call on backend
    await callController.rejectedCall(widget.callId);
    
    global.showToast(
      message: 'Call cancelled',
      textColor: global.textColor,
      bgColor: global.toastBackGoundColor,
    );
  }
}
