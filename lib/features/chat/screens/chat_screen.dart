import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signova/core/constants/colors.dart';
import 'package:signova/core/data/user.dart';
import 'package:signova/features/chat/screens/video_recording_screen.dart';
import 'package:signova/features/chat/service/audio_to_text_service.dart';
import 'package:signova/features/chat/service/chat_service.dart';
import 'package:signova/features/chat/widgets/audio_message_bubble.dart';
import 'package:signova/features/chat/widgets/date_header.dart';
import 'package:signova/features/chat/widgets/text_message_bunddle.dart';
import 'package:signova/features/chat/widgets/video_message_bunddle.dart';
import 'package:signova/features/translation/screens/translation_screen.dart';
import 'package:signova/features/translation/service/gloss_service.dart';
import 'package:signova/features/translation/service/translation_service.dart';
import 'package:signova/features/translation/widgets/text_to_sign_player.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.sessionId,
    required this.receiverUsername,
    this.isReceiverDeaf = false,
  });

  final String sessionId;
  final String receiverUsername;
  final bool isReceiverDeaf;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SpeechToText speechToText = SpeechToText();
  final ImagePicker imagePicker = ImagePicker();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List messages = [];
  bool isLoadingMessages = false;
  String? chatWallpaper;
  Map<String, String> audioTexts = {};

  final Color primaryPurple = const Color(0xFF6B4CF4);
  final Color lightPurpleBg = const Color(0xFFF2F0FF);

  bool get isCurrentUserDeaf => User().isDeaf == true;

  @override
  void initState() {
    super.initState();
    loadWallpaper();
    loadHistory();
  }

  Future<void> loadWallpaper() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      chatWallpaper = prefs.getString("chat_wallpaper_${widget.sessionId}");
    });
  }

  Future<void> pickWallpaper() async {
    final picked = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("chat_wallpaper_${widget.sessionId}", picked.path);

    setState(() {
      chatWallpaper = picked.path;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Wallpaper updated"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> loadHistory() async {
    setState(() => isLoadingMessages = true);
    try {
      final response = await ChatService().getChatHistory(widget.sessionId);
      messages = response.data['data']['messages'] ?? [];

      debugPrint("MESSAGES: $messages");
    } catch (e) {
      debugPrint("History Error: $e");
    }
    setState(() => isLoadingMessages = false);
  }

  Future<void> startListening() async {
    final available = await speechToText.initialize(
      onStatus: (status) => debugPrint("Speech status: $status"),
      onError: (error) => debugPrint("Speech error: $error"),
    );

    if (!available) return;

    await speechToText.listen(
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        setState(() {
          messageController.text = result.recognizedWords;
          messageController.selection = TextSelection.fromPosition(
            TextPosition(offset: messageController.text.length),
          );
        });
      },
    );
  }

  Future<void> pickAndUploadImage() async {
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;

    final file = File(pickedImage.path);

    final tempMessage = {
      "_id": "temp_${DateTime.now().millisecondsSinceEpoch}",
      "sender_id": User().id,
      "type": "image",
      "content": file.path,
      "isUploading": true,
      "isLocal": true,
      "timestamp": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(tempMessage);
    });

    scrollToBottom();

    try {
      final response = await ChatService().uploadChatImage(
        sessionId: widget.sessionId,
        file: file,
      );

      final uploadedMessage = response.data["data"]["message"];

      final index = messages.indexOf(tempMessage);

      if (index != -1) {
        setState(() {
          messages[index] = uploadedMessage;
        });
      }
    } catch (e) {
      final index = messages.indexOf(tempMessage);

      if (index != -1) {
        setState(() {
          messages[index]["isUploading"] = false;
          messages[index]["failed"] = true;
        });
      }

      debugPrint(e.toString());
    }
  }

  Future<void> pickAndUploadAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);

    final tempMessage = {
      "_id": "temp_${DateTime.now().millisecondsSinceEpoch}",
      "sender_id": User().id,
      "type": "audio",
      "content": file.path,
      "isUploading": true,
      "isLocal": true,
      "timestamp": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(tempMessage);
    });

    scrollToBottom();

    try {
      final response = await ChatService().uploadChatAudio(
        sessionId: widget.sessionId,
        file: file,
      );

      final uploadedMessage = response.data["data"]["message"];

      final index = messages.indexOf(tempMessage);

      if (index != -1) {
        setState(() {
          messages[index] = uploadedMessage;
        });
      }
    } catch (e) {
      final index = messages.indexOf(tempMessage);

      if (index != -1) {
        setState(() {
          messages[index]["isUploading"] = false;
          messages[index]["failed"] = true;
        });
      }

      debugPrint(e.toString());
    }
  }

  Future<void> pickAndUploadVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);

    final tempMessage = {
      "_id": "temp_${DateTime.now().millisecondsSinceEpoch}",
      "sender_id": User().id,
      "type": "video",
      "content": file.path,
      "isUploading": true,
      "isLocal": true,
      "timestamp": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(tempMessage);
    });

    scrollToBottom();

    try {
      final response = await ChatService().uploadChatVideo(
        sessionId: widget.sessionId,
        file: file,
      );

      final uploadedMessage = response.data["data"]["message"];

      final index = messages.indexOf(tempMessage);

      if (index != -1) {
        setState(() {
          messages[index] = uploadedMessage;
        });
      }
    } catch (e, s) {
      debugPrint("UPLOAD ERROR: $e");
      debugPrintStack(stackTrace: s);

      final index = messages.indexOf(tempMessage);

      if (index != -1) {
        setState(() {
          messages[index]["isUploading"] = false;
          messages[index]["failed"] = true;
        });
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> pickAndHandleDeafVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);

    final tempMessage = {
      "_id": "temp_${DateTime.now().millisecondsSinceEpoch}",
      "sender_id": User().id,
      "type": "video",
      "content": file.path,
      "isUploading": true,
      "isLocal": true,
      "timestamp": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(tempMessage);
    });

    scrollToBottom();

    try {
      final response = await ChatService().signToTextChat(
        sessionId: widget.sessionId,
        file: file,
      );

      final index = messages.indexOf(tempMessage);
      if (index == -1) return;

      final uploadedMessage = response.data["data"]?["message"];

      setState(() {
        if (uploadedMessage != null) {
          messages[index] = uploadedMessage;
        } else {
          messages[index]["isUploading"] = false;
        }
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isReceiverDeaf
                ? "Video uploaded successfully."
                : "Translation completed successfully.",
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e, s) {
      debugPrint("Handle Deaf Video Error: $e");
      debugPrintStack(stackTrace: s);
      final index = messages.indexOf(tempMessage);
      if (index != -1) {
        setState(() {
          messages[index]["isUploading"] = false;
          messages[index]["failed"] = true;
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> handleDeafVideo(File file) async {
    final tempMessage = {
      "_id": "temp_${DateTime.now().millisecondsSinceEpoch}",
      "sender_id": User().id,
      "type": "video",
      "content": file.path,
      "isUploading": true,
      "isLocal": true,
      "timestamp": DateTime.now().toIso8601String(),
    };
    setState(() {
      messages.add(tempMessage);
    });
    scrollToBottom();
    try {
      final response = await ChatService().signToTextChat(
        sessionId: widget.sessionId,
        file: file,
      );

      final index = messages.indexOf(tempMessage);
      if (index == -1) return;

      final uploadedMessage = response.data["data"]?["message"];

      setState(() {
        if (uploadedMessage != null) {
          messages[index] = uploadedMessage;
        } else {
          messages[index]["isUploading"] = false;
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isReceiverDeaf
                ? "Video uploaded successfully."
                : "Translation completed successfully.",
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e, s) {
      debugPrint("Handle Deaf Video Error: $e");
      debugPrintStack(stackTrace: s);
      final index = messages.indexOf(tempMessage);
      if (index != -1) {
        setState(() {
          messages[index]["isUploading"] = false;
          messages[index]["failed"] = true;
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Image"),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.audiotrack),
                title: const Text("Audio"),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadAudio();
                },
              ),

              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text("Video"),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadVideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String formatTime(String isoTime) {
    final date = DateTime.parse(isoTime).toLocal();
    return "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  Widget buildMessage(Map message) {
    debugPrint("AAAA_FULL_MESSAGE: $message");
    debugPrint("AAAA_USER_ID: ${User().id}");

    final senderId = message['sender_id'] is Map
        ? message['sender_id']['_id']
        : message['sender_id'] ?? message['sender']?['_id'];

    final receiverId = message['receiver_id'] is Map
        ? message['receiver_id']['_id']
        : message['receiver_id'];

    final isMe = senderId.toString() == User().id.toString();

    debugPrint("senderId: $senderId");
    debugPrint("myId: ${User().id}");
    debugPrint("isMe: $isMe");
    debugPrint("messageeeeeeeeee: $message");
    final type = message['type'];
    final content = message['content'] ?? '';
    final videoUrl = message['video_url'];
    final timestamp = message['timestamp'];

    if (type == "translation_text") {
      if (isCurrentUserDeaf) {
        return VideoMessageBubble(
          isMe: isMe,
          time: timestamp != null ? formatTime(timestamp) : "",
          avatarUrl: '',
          primaryColor: primaryPurple,
          videoUrl: videoUrl,
        );
      }

      return TextMessageBubble(
        isMe: isMe,
        time: timestamp != null ? formatTime(timestamp) : "",
        avatarUrl: '',
        text: content,
      );
    }
    if (isCurrentUserDeaf) {
      if (type == "text") {
        return TextMessageBubble(
          isMe: isMe,
          time: timestamp != null ? formatTime(timestamp) : "",
          avatarUrl: '',
          text: content,
          isDeaf: true,
          onPlayTranslation: (position) async {
            FocusManager.instance.primaryFocus?.unfocus();
            final selected = await showModalBottomSheet<SignViewMode>(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),

                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      const SizedBox(height: 16),

                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text("Avatar"),
                        onTap: () =>
                            Navigator.pop(context, SignViewMode.avatar),
                      ),

                      ListTile(
                        leading: const Icon(Icons.accessibility_new),
                        title: const Text("Skeleton"),
                        onTap: () =>
                            Navigator.pop(context, SignViewMode.skeleton),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            );

            if (selected == null) return;

            if (selected == SignViewMode.avatar) {
              final glossJson = await GlossService().textToGlossJson(content);
              debugPrint("GLOSS JSON = $glossJson");
              final Map<String, dynamic> data = jsonDecode(glossJson);
              List<dynamic> glosses = data["glosses"];
              List<String> finalGlosses = [];
              debugPrint("glosses $glosses");
              for (int i = 0; i < glosses.length; i++) {
                String word = glosses[i].toString().trim();
                if (word.toLowerCase() == "blood" &&
                    i + 1 < glosses.length &&
                    glosses[i + 1].toString().trim().toLowerCase() ==
                        "pressure") {
                  debugPrint("Found 'Blood Pressure' at index $i");
                  finalGlosses.add("Blood Pressure");
                  i++;
                  continue;
                }
                if (word.toLowerCase() == "finish") {
                  debugPrint("Found 'My Name' at index $i");
                  finalGlosses.add("finished");
                  i++;
                  continue;
                }
                final formatted =
                    word[0].toUpperCase() + word.substring(1).toLowerCase();
                if (availableSigns.contains(formatted)) {
                  finalGlosses.add(formatted);
                } else {
                  finalGlosses.addAll(
                    word
                        .toUpperCase()
                        .replaceAll(RegExp(r'[^A-Z]'), '')
                        .split(''),
                  );
                }
              }
              data["glosses"] = finalGlosses;
              final formattedGlossJson = jsonEncode(data);
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return Dialog(
                    insetPadding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 500,
                      child: Column(
                        children: [
                          const Divider(height: 1),
                          Expanded(
                            child: EmbedUnity(
                              onMessageFromUnity: (message) {
                                debugPrint(message);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
              Future.delayed(const Duration(milliseconds: 300), () {
                sendToUnity("Jake", "ReceiveGlosses", formattedGlossJson);
              });
            } else {
              if (selected == SignViewMode.skeleton) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("Preparing sign animation..."),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                try {
                  final response = await TranslationService()
                      .standaloneTextToSign(content);

                  // اقفل اللودينج
                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  final videoUrl = response.data["data"]["video_url"];

                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 500,
                        child: TextToSignPlayer(videoUrl: videoUrl),
                      ),
                    ),
                  );
                } catch (e) {
                  // اقفل اللودينج لو حصل خطأ
                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to generate sign animation"),
                    ),
                  );
                }
              }
            }
          },
        );
      }
    }

    if (type == 'image') {
      final avatarUrl = message['sender_id'] is Map
          ? (message['sender_id']['avatar'] ?? '')
          : (message['sender']?['avatar'] ?? '');

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 14,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              SizedBox(width: 2.w),
            ],

            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(content, width: 55.w, fit: BoxFit.cover),
            ),

            if (isMe) ...[
              SizedBox(width: 2.w),
              CircleAvatar(
                radius: 14,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
            ],
          ],
        ),
      );
    }

    if (type == "audio") {
      if (!isCurrentUserDeaf) {
        return AudioMessageBubble(
          isMe: isMe,
          audioUrl: content,
          primaryColor: primaryPurple,
        );
      }

      final id = message["_id"];

      if (audioTexts.containsKey(id)) {
        return TextMessageBubble(
          isMe: isMe,
          time: timestamp != null ? formatTime(timestamp) : "",
          avatarUrl: "",
          text: audioTexts[id]!,
          isDeaf: true,
        );
      }

      AudioToTextService()
          .transcribeAudio(content)
          .then((text) {
            if (!mounted) return;

            setState(() {
              audioTexts[id] = text;
            });
          })
          .catchError((_) {
            if (!mounted) return;

            setState(() {
              audioTexts[id] = "Couldn't recognize speech";
            });
          });

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text("Converting audio..."),
          ],
        ),
      );
    }

    if (type == 'video') {
      final uploading = message["isUploading"] == true;

      if (uploading) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Align(
            alignment: Alignment.centerRight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 55.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.videocam,
                    size: 70,
                    color: Colors.white,
                  ),
                ),

                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return VideoMessageBubble(
        isMe: isMe,
        time: timestamp != null ? formatTime(timestamp) : "",
        avatarUrl: '',
        primaryColor: primaryPurple,
        videoUrl: content,
      );
    }

    return TextMessageBubble(
      isMe: isMe,
      time: timestamp != null ? formatTime(timestamp) : "",
      avatarUrl: '',
      text: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.wallpaper),
            onPressed: pickWallpaper,
          ),
        ],
        title: Text(widget.receiverUsername),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: chatWallpaper != null
              ? DecorationImage(
                  image: FileImage(File(chatWallpaper!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: isLoadingMessages
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        children: _buildChatItems(),
                      ),
              ),
              isCurrentUserDeaf ? _buildDeafBottomActions() : _buildChatInput(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChatItems() {
    List<Widget> items = [];

    String? lastDate;

    for (final message in messages) {
      final timestamp = DateTime.parse(message["timestamp"]);
      final currentDate = formatDateHeader(timestamp);

      if (lastDate != currentDate) {
        items.add(buildDateHeader(currentDate));
        items.add(SizedBox(height: 2.h));
        lastDate = currentDate;
      }

      items.add(buildMessage(message));
    }

    return items;
  }

  String formatDateHeader(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "Today";
    } else if (messageDate == yesterday) {
      return "Yesterday";
    }

    return DateFormat("dd MMM yyyy").format(date);
  }

  Widget _buildChatInput() {
    return Container(
      margin: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 2.h, top: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F9),
        borderRadius: BorderRadius.circular(25.sp),
      ),
      child: Row(
        children: [
          SizedBox(width: 2.w),
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(
                  color: AppColors.hintColor,
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.mic_none, color: primaryPurple, size: 22.sp),
            onPressed: startListening,
          ),
          IconButton(
            icon: Icon(Icons.attach_file, color: primaryPurple, size: 22.sp),
            onPressed: showAttachmentOptions,
          ),
          Container(
            decoration: BoxDecoration(
              color: primaryPurple,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 22.sp),
              onPressed: () async {
                if (messageController.text.trim().isEmpty) return;

                await ChatService().sendTextMessage(
                  sessionId: widget.sessionId,
                  content: messageController.text.trim(),
                );

                messageController.clear();
                await loadHistory();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeafBottomActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: pickAndHandleDeafVideo,
            child: Container(
              width: 13.w,
              height: 13.w,
              decoration: BoxDecoration(
                color: lightPurpleBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: primaryPurple, size: 22.sp),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoRecordingScreen(),
                ),
              );

              if (result != null) {
                await handleDeafVideo(File(result));
              }
            },
            child: Container(
              width: 13.w,
              height: 13.w,
              decoration: BoxDecoration(
                color: primaryPurple,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.videocam, color: Colors.white, size: 22.sp),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: pickAndUploadVideo,
            child: Container(
              width: 13.w,
              height: 13.w,
              decoration: BoxDecoration(
                color: lightPurpleBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.attach_file, color: primaryPurple, size: 22.sp),
            ),
          ),
        ],
      ),
    );
  }
}
