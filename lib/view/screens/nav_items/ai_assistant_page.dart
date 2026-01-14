import 'package:expenxo/providers/ai_provider.dart';
import 'package:expenxo/utils/constands/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    _controller.clear();

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    await Provider.of<AIProvider>(context, listen: false).sendMessage(text);

    // Scroll again after response
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "AI Assistant",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<AIProvider>(
        builder: (context, aiProvider, child) {
          return Column(
            children: [
              // Chat List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      aiProvider.messages.length +
                      (aiProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == aiProvider.messages.length) {
                      // Loading Indicator
                      return _buildLoadingBubble(context);
                    }

                    final msg = aiProvider.messages[index];
                    return _buildChatMessage(
                      context: context,
                      isAI: !msg.isUser,
                      text: msg.text,
                    );
                  },
                ),
              ),

              // Input Area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Ask financial questions...",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded),
                      color: AppColors.mainColor,
                      onPressed: aiProvider.isLoading ? null : _sendMessage,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // For Navbar space if needed
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatMessage({
    required BuildContext context,
    required bool isAI,
    required String text,
  }) {
    final textColor = isAI
        ? Theme.of(context).textTheme.bodyLarge?.color
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isAI
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAI) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.mainColor.withOpacity(0.1),
              child: Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: AppColors.mainColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAI ? Theme.of(context).cardColor : AppColors.mainColor,
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: isAI ? Radius.zero : const Radius.circular(16),
                  bottomRight: isAI ? const Radius.circular(16) : Radius.zero,
                ),
                border: isAI
                    ? Border.all(color: Theme.of(context).dividerColor)
                    : null,
              ),
              child: MarkdownBody(
                data: text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: textColor, fontSize: 14, height: 1.4),
                  strong: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  listBullet: TextStyle(color: textColor),
                ),
              ),
            ),
          ),
          if (!isAI) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person, size: 18, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.mainColor.withOpacity(0.1),
            child: Icon(
              Icons.smart_toy_rounded,
              size: 18,
              color: AppColors.mainColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.mainColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Thinking...",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
