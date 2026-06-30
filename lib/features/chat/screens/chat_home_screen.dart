import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signova/features/chat/service/chat_service.dart';
import 'package:signova/features/chat/screens/chat_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  List sessions = [];
  List users = [];
  bool isLoading = false;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    setState(() => isLoading = true);
    try {
      final response = await ChatService().getSessions();
      sessions = response.data['data']['sessions'] ?? [];
    } catch (e) {
      debugPrint("Load sessions error: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> searchUsers(String query) async {
    query = query.trim();
    if (query.isEmpty) {
      setState(() {
        isSearching = true;
      });

      try {
        final response = await ChatService().searchUsers("");
        users = response.data['data']['results'] ?? [];
      } catch (e) {
        debugPrint("Search users error: $e");
      }

      setState(() {
        isSearching = false;
      });

      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final response = await ChatService().searchUsers(query);
      users = response.data['data']['results'] ?? [];
    } catch (e) {
      debugPrint("Search users error: $e");
    }

    setState(() {
      isSearching = false;
    });
  }

  Future<void> startChat(String username) async {
    try {
      final response = await ChatService().startChat(username);
      final sessionId = response.data['data']['session_id'];

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            sessionId: sessionId,
            receiverUsername: username,
            isReceiverDeaf: false,
          ),
        ),
      ).then((_) {
        loadSessions();
      });
    } catch (e) {
      debugPrint("Start chat error: $e");
    }
  }

  void openSession(Map session) {
    final peer = session['peer'];
    final sessionId = session['session_id'];
    final username = peer?['username'] ?? 'Unknown';
    final isReceiverDeaf = peer?['isDeaf'] == true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          sessionId: sessionId,
          receiverUsername: username,
          isReceiverDeaf: isReceiverDeaf,
        ),
      ),
    ).then((_) {
      loadSessions();
    });
  }

  String getLastMessageText(Map session) {
    final last = session['last_message'];
    if (last == null) return "";
    final type = last['type'];
    final content = last['content'] ?? "";
    if (type == "image") return "📷 Image";
    if (type == "audio") return "🎧 Audio";
    if (type == "video") return "🎥 Video";
    return content;
  }

  String formatTime(String isoTime) {
    final date = DateTime.parse(isoTime).toLocal();
    return "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Chats",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
            child: Container(
              height: 5.h,
              decoration: BoxDecoration(
                color: Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 350), () {
                    searchUsers(value);
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Search by name or number",
                  hintStyle: TextStyle(color: Color(0xFFB2B2B1), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Color(0xFFB2B2B1)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          if (isSearching)
            Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),

          if (users.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user['avatar'] != null
                          ? NetworkImage(user['avatar'])
                          : null,
                      child: user['avatar'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(user['username']),
                    subtitle: Text(user['phone'] ?? ''),
                    onTap: () {
                      startChat(user['username']);
                    },
                  );
                },
              ),
            )
          else if (sessions.isEmpty && !isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 70,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "No chats yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Search for someone to start chatting.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Skeletonizer(
                enabled: isLoading,
                child: RefreshIndicator(
                  onRefresh: loadSessions,
                  child: ListView.builder(
                    itemCount: isLoading ? 8 : sessions.length,
                    itemBuilder: (context, index) {
                      final session = isLoading
                          ? {
                              "peer": {
                                "username": "Loading User",
                                "avatar": null,
                              },
                              "last_message": {
                                "content": "Loading message",
                                "timestamp": DateTime.now().toIso8601String(),
                              },
                            }
                          : sessions[index];

                      final peer = session['peer'];
                      final username = peer?['username'] ?? 'Unknown';
                      final avatar = peer?['avatar'];
                      final lastMessage = session["last_message"];
                      final timestamp = lastMessage?["timestamp"];

                      return Column(
                        children: [
                          InkWell(
                            onTap: () => openSession(session),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: avatar != null
                                        ? NetworkImage(avatar)
                                        : null,
                                    child: avatar == null
                                        ? const Icon(Icons.person, size: 28)
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          getLastMessageText(session),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 4.w),
                                        child: Text(
                                          timestamp != null
                                              ? formatTime(timestamp)
                                              : "",
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      if ((session["unread_count"] ?? 0) > 0)
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Color(0xff25D366),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            "${session["unread_count"]}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.grey.shade300,
                            indent: 16,
                            endIndent: 16,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
