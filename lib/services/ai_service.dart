import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey =
      'AIzaSyDfxzeb8cdZgGdan3CRqu6q8aqD8KeXHHw'; // User needs to replace this
  late final GenerativeModel _model;

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    _isInitialized = true;
  }

  Future<String> sendMessage(String message, String contextData) async {
    if (!_isInitialized) initialize();

    final prompt =
        '''
You are a helpful and knowledgeable financial assistant for the "Expenxo" app. 
Your goal is to help the user manage their money, understand their spending habits, and save more.

Here is the summary of the user's recent financial data:
$contextData

Rules:
1. Answer the user's specific question based on the provided data.
2. If the data is empty text "No data available", tell them you need more transaction history to give specific advice, but give general financial tips.
3. Keep answers concise (max 3-4 sentences unless asked for details).
4. Be encouraging and positive.
5. Format key numbers in bold (e.g., **\$500**).

User Question: $message
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ??
          "I'm having trouble thinking right now. Please try again.";
    } catch (e) {
      if (e.toString().contains('API_KEY') || e.toString().contains('403')) {
        return "It looks like my API Key is missing or invalid. Please check your settings.";
      }
      return "Error: $e";
    }
  }
}
