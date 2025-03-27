import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      title: 'ScamShield',
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

class _AudioAnalyzerScreenState extends State<AudioAnalyzerScreen> with SingleTickerProviderStateMixin {
  List<AudioJob> _jobs = [];
  bool _isProcessing = false;
  late PageController _pageController;
  late AnimationController _animationController;
  final List<InfoCard> _infoCards = [
    InfoCard(
      title: "How ScamShield Works",
      description: "Our advanced AI analyzes audio patterns and linguistic markers to detect potential scam calls.",
      icon: Icons.shield,
    ),
    InfoCard(
      title: "Common Scam Patterns",
      description: "Learn about frequent tactics used by scammers to help protect yourself and others.",
      icon: Icons.warning_amber,
    ),
    InfoCard(
      title: "Stay Protected",
      description: "Regular updates and real-time protection keep you safe from emerging scam tactics.",
      icon: Icons.security,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeProvider.isDarkMode 
              ? [Colors.grey[900]!, Colors.grey[800]!]
              : [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(themeProvider),
            Expanded(
              flex: 3,
              child: _buildUpperSection(),
            ),
            Expanded(
              flex: 2,
              child: _buildInfoCardsSection(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar(ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 16),
          Icon(Icons.shield, color: Colors.blue, size: 28),
          SizedBox(width: 8),
          Text(
            'ScamShield',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
          IconButton(
            icon: Icon(
              Icons.mic,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildUpperSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audio Analysis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _jobs.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _jobs.length,
                  itemBuilder: (context, index) {
                    return _buildJobCard(_jobs[index]);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No audio files analyzed yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Upload an audio file to start analysis',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(AudioJob job) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: job.status == 'Completed'
                ? [Colors.green.withOpacity(0.1), Colors.blue.withOpacity(0.1)]
                : [Colors.blue.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: job.status == 'Completed'
                    ? Colors.green.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.audiotrack,
                color: job.status == 'Completed'
                    ? Colors.green
                    : (job.status == 'Failed' ? Colors.red[300]! : Colors.blue),
              ),
            ),
            title: Text(
              job.fileName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  job.status,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (job.status == 'Processing')
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
              ],
            ),
            trailing: job.status == 'Completed'
                ? ElevatedButton(
                    onPressed: () => _showResultDialog(job),
                    child: Text('View Result'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCardsSection() {
    return Container(
      padding: EdgeInsets.only(bottom: 16),
      child: PageView.builder(
        controller: _pageController,
        itemCount: _infoCards.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }
              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 180,
                  child: child,
                ),
              );
            },
            child: _buildInfoCard(_infoCards[index]),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(InfoCard card) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(card.icon, size: 40, color: Colors.blue),
            SizedBox(height: 12),
            Text(
              card.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              card.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _pickAudioFile,
      icon: Icon(Icons.upload),
      label: Text('Upload Audio'),
      elevation: 4,
    );
  }

void _showResultDialog(AudioJob job) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Analysis Result'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultItem('File', job.fileName),
              _buildResultItem('Status', job.status),
              ..._buildResultItems(job.result),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      );
    },
  );
}

List<Widget> _buildResultItems(Map<String, dynamic>? result) {
  if (result == null) return [Text('No result available')];

  return result.entries.map((entry) {
    return _buildResultItem(entry.key, entry.value.toString());
  }).toList();
}

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(value),
        ],
      ),
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

    AudioJob? job = _jobs.firstWhere(
      (job) => job.status == 'Queued',
      orElse: () => AudioJob(
        fileName: 'Unknown',
        file: File(''),
        status: 'Unknown',
      ),
    );

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
        Uri.parse('https://scam-detection-api.onrender.com/predict-audio'),
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

class InfoCard {
  final String title;
  final String description;
  final IconData icon;

  InfoCard({
    required this.title,
    required this.description,
    required this.icon,
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