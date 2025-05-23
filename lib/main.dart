import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kokoro_tts_flutter/kokoro_tts_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'tools.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kokoro TTS Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Kokoro TTS Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  Future<void> _runTTS() async {
    if (_textController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      const config = KokoroConfig(
        modelPath: 'assets/kokoro-v1.0.onnx',
        voicesPath: 'assets/voices.json',
      );

      final kokoro = Kokoro(config);
      await kokoro.initialize();

      final tokenizer = Tokenizer();
      await tokenizer.ensureInitialized();
      final phonemes = await tokenizer.phonemize(
        _textController.text,
        lang: 'en-us',
      );

      final ttsResult = await kokoro.createTTS(
        text: phonemes,
        voice: 'af_heart',
        isPhonemes: true,
      );

      // 5. Save the audio as a WAV file
      final pcm = ttsResult.toInt16PCM();
      final wavBytes = writeWavFile(pcm, ttsResult.sampleRate);

      // Get temporary directory to save the file
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/output.wav';
      final file = File(filePath);
      await file.writeAsBytes(wavBytes);

      // Play the audio file with just_audio
      final player = AudioPlayer();
      await player.setFilePath(filePath);
      await player.play();

      // 8. Clean up
      await file.delete();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter text to speak',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _runTTS,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Generate Speech'),
            ),
          ],
        ),
      ),
    );
  }
}
