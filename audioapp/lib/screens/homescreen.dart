import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  String? recordingPath;
  bool isRecording = false, isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Audio Recording App",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: Get.width * 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (recordingPath != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: isPlaying ? Colors.white : Colors.blue,
                    textStyle: TextStyle(
                        fontSize: 18,
                        color: isPlaying ? Colors.blue : Colors.white)),
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.stop();
                    setState(() {
                      isPlaying = false;
                    });
                  } else {
                    if (recordingPath != null) {
                      try {
                        await audioPlayer.setFilePath(recordingPath!);
                        await audioPlayer.play();
                        setState(() {
                          isPlaying = true;
                        });
                      } catch (e) {
                        Get.snackbar('Error', 'Could not play recording: $e',
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    isPlaying
                        ? "Stop Playing Recording"
                        : "Start Playing Recording",
                    style: TextStyle(
                        fontSize: 18,
                        color: isPlaying ? Colors.blue : Colors.white),
                  ),
                ),
              ),
              if(recordingPath == null) Center(
                child: Text("No record audio here"),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isRecording) {
            String? filePath = await audioRecorder.stop();
            if (filePath != null) {
              setState(() {
                isRecording = false;
                recordingPath = filePath;
              });
            }
          } else {
            if (await audioRecorder.hasPermission()) {
              final Directory appDocumentsDir =
                  await getApplicationDocumentsDirectory();
              String filePath = p.join(appDocumentsDir.path, 'recording.mp3');
              await audioRecorder.start(const RecordConfig(), path: filePath);
              setState(() {
                recordingPath = null;
                isRecording = true;
              });
            }
          }
        },
        child: Icon(isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }
}
