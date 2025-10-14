import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:agora_rtm/agora_rtm.dart';

/// Agora RTM Service - WhatsApp-like duplex chat system
/// Singleton service for managing real-time messaging
/// Using Agora RTM 2.x API
class AgoraRTMService {
  static final AgoraRTMService _instance = AgoraRTMService._internal();
  factory AgoraRTMService() => _instance;
  AgoraRTMService._internal();

  RtmClient? _client;
  
  String? _currentUserId;
  String? _currentChannelName;
  bool _isInitialized = false;
  bool _isLoggedIn = false;

  // Stream controllers for events
  final StreamController<Map<String, dynamic>> _messageStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _connectionStateController = 
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _typingIndicatorController = 
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get onMessageReceived => _messageStreamController.stream;
  Stream<String> get onConnectionStateChanged => _connectionStateController.stream;
  Stream<Map<String, dynamic>> get onTypingIndicator => _typingIndicatorController.stream;

  /// Initialize RTM client using Agora RTM 2.x API
  Future<bool> initialize(String appId, String userId, String token) async {
    try {
      if (_isInitialized) {
        log('🔥 [AGORA RTM] Already initialized');
        return true;
      }

      log('🚀 [AGORA RTM] Initializing...');
      log('   AppId: $appId');
      log('   UserId: $userId');

      _currentUserId = userId;

      // Create RTM client using new API
      final (status, client) = await RTM(appId, userId);
      
      if (status.error == true) {
        log('❌ [AGORA RTM] Failed to create client: ${status.reason}');
        return false;
      }
      
      _client = client;
      log('✅ [AGORA RTM] Client created successfully');

      // Set up event listeners
      _setupEventHandlers();

      // Login with token
      final (loginStatus, _) = await _client!.login(token);
      if (loginStatus.error == true) {
        log('❌ [AGORA RTM] Login failed: ${loginStatus.reason}');
        return false;
      }
      
      _isLoggedIn = true;
      _isInitialized = true;
      log('✅ [AGORA RTM] Initialized and logged in successfully');
      return true;
    } catch (e) {
      log('❌ [AGORA RTM] Initialization failed: $e');
      return false;
    }
  }

  /// Setup event handlers for Agora RTM 2.x
  void _setupEventHandlers() {
    // Listen to message events using addListener
    _client?.addListener(
      message: (event) {
        try {
          // Decode message from Uint8List to String
          String messageText = utf8.decode(event.message!);
          log('📩 [AGORA RTM] Message received: $messageText');
          _handleIncomingMessage(messageText, event.publisher ?? 'unknown', event.channelName ?? '');
        } catch (e) {
          log('❌ [AGORA RTM] Failed to decode message: $e');
        }
      },
      linkState: (event) {
        log('🔌 [AGORA RTM] Link state: ${event.previousState} → ${event.currentState}');
        log('   Reason: ${event.reason}, Operation: ${event.operation}');
        _connectionStateController.add('link_${event.currentState}');
      },
      presence: (event) {
        log('👥 [AGORA RTM] Presence event: ${event.type}');
        _connectionStateController.add('presence_${event.type}');
      },
    );
    
    log('✅ [AGORA RTM] Event handlers set up');
  }

  /// Subscribe to channel (Agora RTM 2.x replaces "join")
  Future<bool> joinChannel(String channelName) async {
    try {
      if (!_isInitialized || !_isLoggedIn) {
        log('❌ [AGORA RTM] Not initialized or not logged in');
        return false;
      }

      log('🔗 [AGORA RTM] Subscribing to channel: $channelName');

      // Unsubscribe from current channel if exists
      if (_currentChannelName != null) {
        await leaveChannel();
      }

      // Subscribe to channel using new API
      final (status, _) = await _client!.subscribe(channelName);
      
      if (status.error == true) {
        log('❌ [AGORA RTM] Subscribe failed: ${status.reason}');
        return false;
      }
      
      _currentChannelName = channelName;
      log('✅ [AGORA RTM] Subscribed to channel successfully');
      return true;
    } catch (e) {
      log('❌ [AGORA RTM] Failed to subscribe to channel: $e');
      return false;
    }
  }

  /// Publish message to channel (Agora RTM 2.x API)
  Future<bool> sendChannelMessage(
    String messageText, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_currentChannelName == null) {
        log('❌ [AGORA RTM] No channel subscribed');
        return false;
      }

      Map<String, dynamic> messageData = {
        'message': messageText,
        'senderId': _currentUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'type': 'text',
        ...?metadata,
      };

      String jsonMessage = jsonEncode(messageData);

      // Publish using new API
      final (status, _) = await _client!.publish(
        _currentChannelName!,
        jsonMessage,
        channelType: RtmChannelType.message,
        customType: 'PlainText',
      );
      
      if (status.error == true) {
        log('❌ [AGORA RTM] Publish failed: ${status.reason}');
        return false;
      }

      log('✅ [AGORA RTM] Message published to channel');
      return true;
    } catch (e) {
      log('❌ [AGORA RTM] Failed to send message: $e');
      return false;
    }
  }

  /// Send peer-to-peer message (currently disabled in RTM 2.x for messaging channels)
  /// Use channel-based communication instead
  Future<bool> sendPeerMessage(
    String peerId,
    String messageText, {
    Map<String, dynamic>? metadata,
  }) async {
    log('⚠️ [AGORA RTM] P2P messaging not recommended in RTM 2.x');
    log('   Use channel-based communication instead');
    return false;
  }

  /// Send typing indicator via channel
  Future<void> sendTypingIndicator(bool isTyping) async {
    try {
      if (_currentChannelName == null) return;

      Map<String, dynamic> typingData = {
        'type': 'typing',
        'isTyping': isTyping,
        'senderId': _currentUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      String jsonMessage = jsonEncode(typingData);
      
      await _client!.publish(
        _currentChannelName!,
        jsonMessage,
        channelType: RtmChannelType.message,
        customType: 'TypingIndicator',
      );
    } catch (e) {
      log('❌ [AGORA RTM] Failed to send typing indicator: $e');
    }
  }

  /// Send read receipt via channel
  Future<void> sendReadReceipt(List<String> messageIds) async {
    try {
      if (_currentChannelName == null) return;

      Map<String, dynamic> receiptData = {
        'type': 'read_receipt',
        'messageIds': messageIds,
        'senderId': _currentUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      String jsonMessage = jsonEncode(receiptData);
      
      await _client!.publish(
        _currentChannelName!,
        jsonMessage,
        channelType: RtmChannelType.message,
        customType: 'ReadReceipt',
      );
    } catch (e) {
      log('❌ [AGORA RTM] Failed to send read receipt: $e');
    }
  }

  /// Handle incoming message
  void _handleIncomingMessage(String messageText, String senderId, String channelName) {
    try {
      Map<String, dynamic> messageData = jsonDecode(messageText);
      
      String type = messageData['type'] ?? 'text';
      
      switch (type) {
        case 'typing':
          _typingIndicatorController.add(messageData);
          break;
        case 'read_receipt':
          _messageStreamController.add({
            ...messageData,
            'eventType': 'read_receipt',
          });
          break;
        default:
          // Regular message
          _messageStreamController.add({
            ...messageData,
            'eventType': 'message',
            'channelName': channelName,
            'senderId': senderId,
          });
      }
    } catch (e) {
      log('❌ [AGORA RTM] Failed to parse message: $e');
    }
  }

  /// Unsubscribe from current channel
  Future<void> leaveChannel() async {
    try {
      if (_currentChannelName != null) {
        final (status, _) = await _client!.unsubscribe(_currentChannelName!);
        if (status.error == false) {
          log('✅ [AGORA RTM] Unsubscribed from channel');
        }
        _currentChannelName = null;
      }
    } catch (e) {
      log('❌ [AGORA RTM] Failed to unsubscribe from channel: $e');
    }
  }

  /// Logout from RTM
  Future<void> logout() async {
    try {
      await leaveChannel();
      
      if (_client != null && _isLoggedIn) {
        final (status, _) = await _client!.logout();
        if (status.error == false) {
          log('✅ [AGORA RTM] Logged out');
        }
        _isLoggedIn = false;
      }
    } catch (e) {
      log('❌ [AGORA RTM] Failed to logout: $e');
    }
  }

  /// Release client
  Future<void> destroy() async {
    try {
      await logout();
      
      if (_client != null) {
        // Note: Agora RTM 2.x doesn't require explicit client destruction
        // Client cleanup happens automatically
        _client = null;
        _isInitialized = false;
        log('✅ [AGORA RTM] Client released');
      }
    } catch (e) {
      log('❌ [AGORA RTM] Failed to release client: $e');
    }
  }

  /// Dispose streams
  void dispose() {
    _messageStreamController.close();
    _connectionStateController.close();
    _typingIndicatorController.close();
  }

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserId => _currentUserId;
  String? get currentChannelName => _currentChannelName;
}
