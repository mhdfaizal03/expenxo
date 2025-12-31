import 'package:flutter/material.dart';

class AIAssistantPage extends StatelessWidget {
  const AIAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Container(
              height: 40,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'AI Assistant',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // AI Message
                _buildChatMessage(
                  isAI: true,
                  text:
                      "Hello! I'm your AI financial assistant. How can I help you today?",
                ),
                // User Message
                _buildChatMessage(
                  isAI: false,
                  text: "I want to save more money next month.",
                ),
                // AI Detailed Response
                _buildChatMessage(
                  isAI: true,
                  text:
                      "That's a great goal! Let's explore some strategies. Are you interested in budgeting, tracking specific expenses, or finding saving opportunities?",
                ),

                const SizedBox(height: 16),

                // Suggested Question Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSuggestChip(
                        "How much did I spend on groceries last month?",
                      ),
                      const SizedBox(width: 8),
                      _buildSuggestChip("What's my net savings?"),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  "AI Tips & Suggestions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Spending Alert Card
                _buildInsightCard(
                  icon: Icons.lightbulb_outline,
                  title: "Spending Alert: Food Expenses Up",
                  description:
                      "You spent 15% more on food and dining this month compared to last. Reviewing your habits could help you save.",
                  actions: ["Create New Budget", "View Transactions"],
                ),

                const SizedBox(height: 16),

                // Subscription Reminder Card
                _buildInsightCard(
                  icon: Icons.subscriptions_outlined,
                  title: "Subscription Reminder",
                  description:
                      "You have several active subscriptions. Would you like a breakdown to see where you can cut back?",
                  actions: ["Review Subscriptions", "Track Spending"],
                ),
              ],
            ),
          ),

          // Chat Input Area
          _buildInputArea(),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildChatMessage({required bool isAI, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isAI
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAI) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFF1F4F8),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 16,
                color: Color(0xFF00C9A7),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAI ? Colors.white : const Color(0xFF00C9A7),
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: isAI
                      ? const Radius.circular(0)
                      : const Radius.circular(16),
                  bottomRight: isAI
                      ? const Radius.circular(16)
                      : const Radius.circular(0),
                ),
                border: isAI
                    ? Border.all(color: const Color(0xFFE2E8F0))
                    : null,
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isAI ? Colors.black87 : Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!isAI) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=user'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> actions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF00C9A7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: const Color(0xFF00C9A7), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: actions
                          .map(
                            (action) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF00C9A7),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    action,
                                    style: const TextStyle(
                                      color: Color(0xFF00C9A7),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Ask me anything about your finances...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF1F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF86E3D0),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
