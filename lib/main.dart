import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'real_time.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Scam Audio Analyzer',
      theme: themeProvider.themeData,
      home: AudioAnalyzerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AudioAnalyzerScreen extends StatefulWidget {
  @override
  _AudioAnalyzerScreenState createState() => _AudioAnalyzerScreenState();
}

class _AudioAnalyzerScreenState extends State<AudioAnalyzerScreen> {
  List<AudioJob> _jobs = [];
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Scam Audio Analyzer'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(Icons.mic), // Mic icon for real-time analysis
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AudioAnalyzerScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _jobs.length,
              itemBuilder: (context, index) {
                return _buildJobCard(_jobs[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _pickAudioFile,
              icon: Icon(Icons.upload),
              label: Text('Upload Audio File'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(AudioJob job) {
    return Card(
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
  contentPadding: EdgeInsets.all(16),
  leading: Icon(
    Icons.audiotrack,
    color: job.status == 'Completed'
        ? Colors.green
        : (job.status == 'Failed'
            ? Colors.red[300]!
            : Colors.blue),
  ),
        title: Text(
          job.fileName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          job.status,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: job.status == 'Completed'
            ? ElevatedButton(
                onPressed: () {
                  _showResultDialog(job);
                },
                child: Text('View Result'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  void _showResultDialog(AudioJob job) {

    

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Analysis Result'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('File: ${job.fileName}'),
                SizedBox(height: 8),
                Text('Status: ${job.status}'),
                SizedBox(height: 8),
                Text('Result: ${jsonEncode(job.result)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      setState(() {
        _jobs.add(AudioJob(fileName: fileName, file: file, status: 'Queued'));
      });

      if (!_isProcessing) {
        _processNextJob();
      }
    }
  }

  void _processNextJob() async {
    if (_jobs.isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Find the first job that is queued
    AudioJob? job = _jobs.firstWhere((job) => job.status == 'Queued', orElse: () => AudioJob(
    fileName: 'Unknown',
    file: File(''),
    status: 'Unknown',
  ),);

    if (job.status == 'Unknown') {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    setState(() {
      job.status = 'Processing';
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://scam-detection-api.onrender.com/predict-audio'), // Replace with your API endpoint
      );
      request.files.add(await http.MultipartFile.fromPath('audio', job.file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var result = jsonDecode(responseData);

        setState(() {
          job.status = 'Completed';
          job.result = result;
        });
      } else {
        setState(() {
          job.status = 'Failed';
        });
      }
    } catch (e) {
      setState(() {
        job.status = 'Failed';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });

      // Process the next job in the queue
      _processNextJob();
    }
  }
}

class AudioJob {
  String fileName;
  File file;
  String status;
  Map<String, dynamic>? result;

  AudioJob({
    required this.fileName,
    required this.file,
    required this.status,
    this.result,
  });
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  static final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
    ),
  ));

  static final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
    ),
  ));
}