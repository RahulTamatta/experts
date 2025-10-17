import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/views/call/accept_call_screen.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

/// 📞 WhatsApp-Like: Show incoming call dialog for customer
/// This shows when expert calls the customer back
Future<void> showIncomingCallDialog({
  required BuildContext context,
  required int astrologerId,
  required String astrologerName,
  required String astrologerProfile,
  required String token,
  required String channelName,
  required int callId,
  required int callType, // 10 = audio, 11 = video
  required String duration,
  String? appId,
}) async {
  print('📞 [CUSTOMER INCOMING] ══════════════════════════');
  print('📞 [CUSTOMER INCOMING] Showing incoming call dialog');
  print('📞 [CUSTOMER INCOMING] Call ID: $callId');
  print('📞 [CUSTOMER INCOMING] Astrologer: $astrologerName (ID: $astrologerId)');
  print('📞 [CUSTOMER INCOMING] Call Type: ${callType == 10 ? "Audio" : "Video"}');
  print('📞 [CUSTOMER INCOMING] Channel: $channelName');
  print('📞 [CUSTOMER INCOMING] Token (first 30): ${token.length > 30 ? token.substring(0, 30) : token}...');
  print('📞 [CUSTOMER INCOMING] ══════════════════════════');
  
  final callController = Get.find<CallController>();
  
  Get.dialog(
    WillPopScope(
      onWillPop: () async => false, // Can't dismiss by tapping outside
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Incoming call indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone_in_talk, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Incoming Call',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Astrologer profile picture
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: ClipOval(
                  child: astrologerProfile.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: astrologerProfile,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Icon(Icons.person, size: 40),
                          errorWidget: (context, url, error) => const Icon(Icons.person, size: 40),
                        )
                      : const Icon(Icons.person, size: 40),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Astrologer name
              Text(
                astrologerName.isNotEmpty ? astrologerName : 'Astrologer',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Call type
              Text(
                callType == 10 ? 'Voice Call' : 'Video Call',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Accept/Reject buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'reject_customer',
                        onPressed: () => _rejectCall(callId, callController),
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.call_end, size: 28),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Decline',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  
                  // Accept button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'accept_customer',
                        onPressed: () => _acceptCall(
                          callId,
                          astrologerId,
                          astrologerName,
                          astrologerProfile,
                          token,
                          channelName,
                          duration,
                          callController,
                          appId,
                        ),
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.call, size: 28),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Accept',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

Future<void> _acceptCall(
  int callId,
  int astrologerId,
  String astrologerName,
  String astrologerProfile,
  String token,
  String channelName,
  String duration,
  CallController callController,
  String? appId,
) async {
  print('📞 [CUSTOMER ACCEPT] ══════════════════════════');
  print('✅ [CUSTOMER ACCEPT] Customer accepting call ID: $callId');
  print('✅ [CUSTOMER ACCEPT] Astrologer: $astrologerName (ID: $astrologerId)');
  print('✅ [CUSTOMER ACCEPT] Duration: $duration seconds');
  print('✅ [CUSTOMER ACCEPT] Channel: $channelName');
  print('✅ [CUSTOMER ACCEPT] Token available: ${token.isNotEmpty}');
  print('📞 [CUSTOMER ACCEPT] ══════════════════════════');
  
  // Close dialog
  print('🔒 [CUSTOMER ACCEPT] Closing incoming call dialog...');
  Get.back();
  
  // Show loader
  print('⏳ [CUSTOMER ACCEPT] Showing loader while accepting...');
  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );
  
  try {
    print('🌐 [CUSTOMER ACCEPT] Calling backend acceptedCall...');
    // Call backend to accept
    await callController.acceptedCall(callId);
    print('✅ [CUSTOMER ACCEPT] Backend accepted successfully');
    
    // Close loader
    Get.back();
    
    print('🚀 [CUSTOMER ACCEPT] Navigating to AcceptCallScreen...');
    print('🚀 [CUSTOMER ACCEPT] Astrologer ID: $astrologerId');
    print('🚀 [CUSTOMER ACCEPT] Call ID: $callId');
    print('🚀 [CUSTOMER ACCEPT] Agora Channel: $channelName');
    print('🚀 [CUSTOMER ACCEPT] Agora Token length: ${token.length}');
    
    // Navigate to call screen
    Get.to(() => AcceptCallScreen(
      astrologerId: astrologerId,
      astrologerName: astrologerName,
      astrologerProfile: astrologerProfile,
      token: token,
      callChannel: channelName,
      callId: callId,
      duration: duration,
      isfromnotification: false,
      appId: appId,
    ));
    print('✅ [CUSTOMER ACCEPT] Navigation completed');
    
  } catch (e) {
    // Close loader
    Get.back();
    
    print('❌ [CUSTOMER ACCEPT] Error accepting call: $e');
    print('❌ [CUSTOMER ACCEPT] Stack trace: ${StackTrace.current}');
    
    global.showToast(
      message: 'Failed to accept call',
      textColor: global.textColor,
      bgColor: global.toastBackGoundColor,
    );
  }
}

Future<void> _rejectCall(
  int callId,
  CallController callController,
) async {
  print('❌ [CUSTOMER REJECT] Rejecting call ID: $callId');
  
  // Close dialog
  Get.back();
  
  try {
    // Call backend to reject
    await callController.rejectedCall(callId);
    
    global.showToast(
      message: 'Call declined',
      textColor: global.textColor,
      bgColor: global.toastBackGoundColor,
    );
    
  } catch (e) {
    print('❌ [CUSTOMER REJECT] Error rejecting call: $e');
  }
}
