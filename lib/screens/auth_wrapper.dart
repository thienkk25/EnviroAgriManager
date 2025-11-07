import 'package:enviro_agri_manager/models/message_model.dart';
import 'package:enviro_agri_manager/providers/ai_provider.dart';
import 'package:enviro_agri_manager/providers/auth_provider.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/widgets/chat_bubble.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollChipController = ScrollController();
  double _dragStart = 0.0;
  double _scrollStart = 0.0;
  bool _isSuggestionVisible = false;
  final question = [
    'Cách bón phân cho lúa?',
    'Phòng bệnh vàng lá?',
    'Tưới nhỏ giọt là gì?',
    'Cây xoài bị rụng lá non là do nguyên nhân gì?',
    'Bao lâu nên tưới nước cho cây dưa leo?',
    'Cách trồng cà chua để ra quả sai nhất là gì?',
  ];

  bool _showBotAI = true;
  bool _isDragging = false;

  double leftPosition = 0;
  double topPosition = 0;

  @override
  void initState() {
    super.initState();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _scrollChipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    if (!_isDragging) {
      leftPosition = screenSize.width - 80;
      topPosition = screenSize.height - 200;
    }
    final authProvider = context.watch<AuthProvider>();
    final isOnline = context.watch<ConnectivityProvider>().isOnline;

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.isSignedIn) {
      return Scaffold(
        body: Stack(
          children: [
            const MainScreen(),
            if (!isOnline)
              Positioned(
                top: 10,
                left: 0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: .8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.transparent,

                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Đang ở chế độ Offline",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_showBotAI)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                curve: Curves.ease,
                left: leftPosition,
                top: topPosition,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _isDragging = true;
                      leftPosition += details.delta.dx;
                      topPosition += details.delta.dy;
                      leftPosition = leftPosition.clamp(
                        0.0,
                        screenSize.width - 80,
                      );
                      topPosition = topPosition.clamp(
                        0.0,
                        screenSize.height - 80,
                      );
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      if (leftPosition > screenSize.width / 2) {
                        leftPosition = screenSize.width - 80;
                      } else {
                        leftPosition = 10;
                      }
                    });
                  },
                  onTap: () {
                    _isSuggestionVisible = false;
                    _showChatBotAI(context);
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.smart_toy,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => setState(() => _showBotAI = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 3),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return const LoginScreen();
  }

  void _showChatBotAI(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Đóng chat bot',
      barrierColor: Colors.black.withValues(alpha: .4),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        final size = MediaQuery.of(context).size;
        return Consumer<AiProvider>(
          builder: (context, aiProvider, child) {
            return Align(
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: AnimatedPadding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: Container(
                    width: size.width * 0.9,
                    height: size.height * 0.75,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(
                                    Icons.smart_toy,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Trợ lý Nông nghiệp AI',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        Expanded(
                          child: StreamBuilder<List<Message>>(
                            stream: aiProvider.messageStream,
                            initialData: aiProvider.currentMessages,
                            builder: (context, snapshot) {
                              final messages = snapshot.data ?? [];
                              _scrollToBottom();
                              return ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                itemCount: messages.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return const Align(
                                      alignment: Alignment.centerLeft,
                                      child: ChatBubble(
                                        text:
                                            'Xin chào! Tôi là Bot trợ lý Nông nghiệp và Môi trường AI 🌾.Bạn có muốn Bot hỗ trợ về vấn đề gì hôm nay không?',
                                        isUser: false,
                                      ),
                                    );
                                  }

                                  final msg = messages[index - 1];
                                  return Align(
                                    alignment: msg.sender == 'user'
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: ChatBubble(
                                      text: msg.content,
                                      isUser: msg.sender == 'user',
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 8),
                        if (!_isSuggestionVisible)
                          Listener(
                            onPointerSignal: (event) {
                              if (event is PointerScrollEvent) {
                                _scrollChipController.jumpTo(
                                  _scrollChipController.offset +
                                      event.scrollDelta.dy,
                                );
                              }
                            },
                            child: GestureDetector(
                              onHorizontalDragStart: (details) {
                                _dragStart = details.globalPosition.dx;
                                _scrollStart = _scrollChipController.offset;
                              },
                              onHorizontalDragUpdate: (details) {
                                final delta =
                                    _dragStart - details.globalPosition.dx;
                                _scrollChipController.jumpTo(
                                  _scrollStart + delta,
                                );
                              },
                              child: SizedBox(
                                height: 40,
                                child: ListView.builder(
                                  controller: _scrollChipController,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: question.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ActionChip(
                                      backgroundColor: Colors.blue.shade50,
                                      labelStyle: const TextStyle(
                                        color: Colors.blueAccent,
                                      ),
                                      label: Text(question[index]),
                                      onPressed: () {
                                        aiProvider.sendMessage(
                                          question[index],
                                          context
                                              .read<ConnectivityProvider>()
                                              .isOnline,
                                        );
                                        _isSuggestionVisible = true;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 8),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  decoration: const InputDecoration(
                                    hintText: 'Nhập câu hỏi cho bot...',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  onSubmitted: (_) {
                                    if (_controller.text.trim().isNotEmpty) {
                                      aiProvider.sendMessage(
                                        _controller.text.trim(),
                                        context
                                            .read<ConnectivityProvider>()
                                            .isOnline,
                                      );
                                      _controller.clear();
                                      _isSuggestionVisible = true;
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  if (_controller.text.trim().isNotEmpty) {
                                    aiProvider.sendMessage(
                                      _controller.text.trim(),
                                      context
                                          .read<ConnectivityProvider>()
                                          .isOnline,
                                    );
                                    _controller.clear();
                                    _isSuggestionVisible = true;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },

      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }
}
