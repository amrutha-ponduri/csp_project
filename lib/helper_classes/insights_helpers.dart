import 'package:http/http.dart' as http;
import 'dart:convert';

class Insights {

  Future<String> getAIResponse(String prompt) async {
    final response = await http.post(
      Uri.parse('https://us-central1-smart-expend.cloudfunctions.net/geminiPredict'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['predictions'][0]['content']; // Adjust as per response
    } else {
      throw Exception('Failed to get AI response');
    }

  }
  Future<String> categorizeExpenses({required Map<String, dynamic> expenses}) async {
    // Step 1: Format the list into a string
    String formattedExpenses = '${expenses['name']} ${expenses['amount']}';

    // Step 2: Create the prompt
    String prompt = '''
  Categorize the following expenses based on their name and amount into one of these categories: 
  Food, Entertainment, Technology, Education.

  Expenses: $formattedExpenses

  Return each item's category like this:
  "Entertainment"
  ''';

    // Step 3: Send prompt to Gemini
    try {
      String response = await getAIResponse(prompt);
      return response;
    } catch (e) {
      return e.toString();
    }
  }
}

