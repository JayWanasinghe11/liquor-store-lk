import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'AIzaSyB_roqECyyhELrk38OMvrQ6IB910ft_P_s',
  );

  Future<String> getDrinkSuggestion(String message) async {
    try {
      final content = [
        Content.text("You are a helpful Sri Lankan liquor expert. $message"),
      ];
      final response = await model.generateContent(content);

      return response.text ?? "Mchan, mata hithaganna ba eka.";
    } catch (e) {
      print("Gemini Error: $e");
      return "Error ekak awa mchan. Poddak check karapan.";
    }
  }
}
