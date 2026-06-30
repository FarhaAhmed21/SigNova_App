import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:signova/features/translation/widgets/custom_toggle_switch.dart';
import 'package:signova/features/translation/widgets/input_field_voice.dart';
import 'package:signova/features/translation/widgets/sign_to_text_widget.dart';
import 'package:signova/features/translation/widgets/text_to_sign_player.dart';
import 'package:sizer/sizer.dart';
import 'package:signova/features/translation/service/translation_service.dart';
import 'dart:io';
import 'package:signova/features/chat/screens/video_recording_screen.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:signova/features/translation/service/gloss_service.dart';

enum SignViewMode { avatar, skeleton }

SignViewMode signViewMode = SignViewMode.avatar;
String? skeletonVideoUrl;

final Set<String> availableSigns = {
  "ADHD",
  "App",
  "Bank",
  "Basketball",
  "Bathroom",
  "Yourself",
  "Bedroom",
  "Benefit",
  "Blue",
  "Bye",
  "By Near",
  "Brother",
  "Borrow",
  "Book Extended",
  "Busy",
  "Buy",
  "Call Phone",
  "Celebrate",
  "Check",
  "Aspirin",
  "Finished",
  "Blood Pressure",
  "Brown",
  "Burger",
  "Business",
  "Camera",
  "Carefully",
  "Hello",
  "My",
  "My Name",
  "Please",
  "Take",
  "This",
  "Turn Off",
  "Where",
  "Which",
  "You",
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "K",
  "L",
  "M",
  "N",
  "O",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "U",
  "V",
  "W",
  "X",
  "Y",
  "Z",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "0",
};

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  bool _isTextToSign = true;
  double _previousScale = 1;
  final GlobalKey uploadKey = GlobalKey();
  final GlobalKey cameraKey = GlobalKey();
  final Color primaryPurple = const Color(0xFF6B4CF4);
  final Color lightGreyBackground = const Color(0xFFF7F8FA);
  final TextEditingController _controller = TextEditingController();
  String? videoUrl;
  bool isLoading = false;
  String translatedText = "";
  final SpeechToText speechToText = SpeechToText();
  bool _startedTutorial = false;
  late BuildContext _showcaseContext;

  @override
  void initState() {
    super.initState();
  }

  Future<void> translateText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    debugPrint("Translating text: $text");
    setState(() => isLoading = true);

    try {
      final glossJson = await GlossService().textToGlossJson(text);
      debugPrint("GLOSS JSON = $glossJson");
      setState(() {
        debugPrint("GLOSS JSON = $glossJson");
        translatedText = glossJson;
      });
      if (!mounted) return;
      debugPrint("signViewMode = $signViewMode");
      if (signViewMode == SignViewMode.avatar) {
        debugPrint("GLOSS JSON = $glossJson");
        final Map<String, dynamic> data = jsonDecode(glossJson);
        List<dynamic> glosses = data["glosses"];
        List<String> finalGlosses = [];
        debugPrint("glosses $glosses");
        for (int i = 0; i < glosses.length; i++) {
          String word = glosses[i].toString().trim();
          if (word.toLowerCase() == "blood" &&
              i + 1 < glosses.length &&
              glosses[i + 1].toString().trim().toLowerCase() == "pressure") {
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
              word.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '').split(''),
            );
          }
        }
        data["glosses"] = finalGlosses;

        final formattedGlossJson = jsonEncode(data);
        debugPrint("Formatted JSON = $formattedGlossJson");
        sendToUnity("Jake", "ReceiveGlosses", formattedGlossJson);
      } else {
        final response = await TranslationService().standaloneTextToSign(text);
        setState(() {
          skeletonVideoUrl = response.data["data"]["video_url"];
        });
      }
    } catch (e) {
      debugPrint("Gloss error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gloss error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> translateVideo(File videoFile) async {
    setState(() {
      isLoading = true;
    });

    try {
      final res = await TranslationService().standaloneSignToText(videoFile);

      setState(() {
        translatedText = res.data['data']['text'] ?? '';
      });
    } catch (e) {
      debugPrint("Sign to text error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> startListening() async {
    final available = await speechToText.initialize();

    if (!available) return;

    await speechToText.listen(
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
    );
  }

  Future<void> _showTutorialIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();

    final firstTime = prefs.getBool("translationTutorial") ?? true;

    if (!firstTime) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowCaseWidget.of(_showcaseContext).startShowCase([uploadKey, cameraKey]);
    });

    await prefs.setBool("translationTutorial", false);
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (showcaseContext) {
        _showcaseContext = showcaseContext;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: CustomToggleSwitch(
                    isTextToSignInitial: true,
                    onChanged: (bool value) async {
                      setState(() {
                        _isTextToSign = value;
                      });

                      if (!value) {
                        await _showTutorialIfNeeded();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: IndexedStack(
                          index: _isTextToSign ? 0 : 1,
                          children: [
                            signViewMode == SignViewMode.avatar
                                ? GestureDetector(
                                    onScaleUpdate: (details) {
                                      // إصبع واحد -> Drag
                                      if (details.pointerCount == 1) {
                                        sendToUnity(
                                          "Jake",
                                          "DragView",
                                          '{"dx":${details.focalPointDelta.dx},"dy":${details.focalPointDelta.dy}}',
                                        );
                                      }

                                      // إصبعين -> Zoom
                                      if (details.pointerCount == 2) {
                                        if (details.scale >
                                            _previousScale + 0.02) {
                                          sendToUnity("Jake", "ZoomView", "IN");
                                        } else if (details.scale <
                                            _previousScale - 0.02) {
                                          sendToUnity(
                                            "Jake",
                                            "ZoomView",
                                            "OUT",
                                          );
                                        }

                                        _previousScale = details.scale;
                                      }
                                    },
                                    onScaleEnd: (_) {
                                      _previousScale = 1;
                                    },
                                    child: EmbedUnity(
                                      onMessageFromUnity: (message) {
                                        debugPrint(
                                          "Message from Unity: $message",
                                        );
                                        // if (message == "UNITY_READY") {
                                        //   for (int i = 0; i < 4; i++) {
                                        //     sendToUnity("Jake", "ZoomView", "IN");
                                        //     await Future.delayed(
                                        //       const Duration(milliseconds: 100),
                                        //     );
                                        //   }
                                        // }
                                      },
                                    ),
                                  )
                                : TextToSignPlayer(
                                    videoUrl: skeletonVideoUrl ?? "",
                                  ),

                            buildSignToTextView(
                              uploadKey: uploadKey,
                              cameraKey: cameraKey,
                              translatedText: translatedText,
                              isLoading: isLoading,
                              onUploadTap: () async {
                                final result = await FilePicker.platform
                                    .pickFiles(type: FileType.video);

                                if (result != null) {
                                  final file = File(result.files.single.path!);
                                  await translateVideo(file);
                                }
                              },
                              onRecordTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const VideoRecordingScreen(),
                                  ),
                                );
                                if (result != null) {
                                  await translateVideo(File(result));
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      if (_isTextToSign)
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: GestureDetector(
                            onTapDown: (TapDownDetails details) async {
                              final value = await showMenu<SignViewMode>(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  details.globalPosition.dx,
                                  details.globalPosition.dy,
                                  details.globalPosition.dx,
                                  details.globalPosition.dy,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                items: const [
                                  PopupMenuItem(
                                    value: SignViewMode.avatar,
                                    child: Row(
                                      children: [
                                        Icon(Icons.person),
                                        SizedBox(width: 10),
                                        Text("Avatar"),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: SignViewMode.skeleton,
                                    child: Row(
                                      children: [
                                        Icon(Icons.accessibility_new),
                                        SizedBox(width: 10),
                                        Text("Skeleton"),
                                      ],
                                    ),
                                  ),
                                ],
                              );

                              if (value != null) {
                                FocusManager.instance.primaryFocus?.unfocus();

                                setState(() {
                                  signViewMode = value;
                                });
                              }
                            },
                            // onTap: () {
                            //   showModalBottomSheet(
                            //     context: context,
                            //     builder: (_) => Column(
                            //       mainAxisSize: MainAxisSize.min,
                            //       children: [
                            //         ListTile(
                            //           leading: const Icon(Icons.person),
                            //           title: const Text("Avatar"),
                            //           onTap: () {
                            //             FocusScope.of(context).unfocus();
                            //             setState(() {
                            //               signViewMode = SignViewMode.avatar;
                            //             });
                            //             Navigator.pop(context);
                            //             Future.delayed(Duration.zero, () {
                            //               FocusManager.instance.primaryFocus
                            //                   ?.unfocus();
                            //             });
                            //           },
                            //         ),
                            //         ListTile(
                            //           leading: const Icon(Icons.accessibility_new),
                            //           title: const Text("Skeleton"),
                            //           onTap: () {
                            //             FocusScope.of(context).unfocus();
                            //             setState(() {
                            //               signViewMode = SignViewMode.skeleton;
                            //             });
                            //             Navigator.pop(context);
                            //             Future.delayed(Duration.zero, () {
                            //               FocusManager.instance.primaryFocus
                            //                   ?.unfocus();
                            //             });
                            //           },
                            //         ),
                            //       ],
                            //     ),
                            //   );
                            // },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 8,
                                    color: Colors.black12,
                                  ),
                                ],
                              ),
                              child: Icon(
                                signViewMode == SignViewMode.avatar
                                    ? Icons.person
                                    : Icons.accessibility_new,
                                color: primaryPurple,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_isTextToSign)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: buildInputField(
                      controller: _controller,
                      onMicTap: startListening,
                      translateText: translateText,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
