import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:provider/provider.dart';
import 'package:scamshield/main.dart';
import 'package:phone_state/phone_state.dart';
class AudioAnalyzerScreen extends StatefulWidget {
  @override
  _AudioAnalyzerScreenState createState() => _AudioAnalyzerScreenState();
}


class CallMonitor {
  final Function(Map<String, dynamic>) onScamDetected;

  CallMonitor({required this.onScamDetected});

  Future<void> initialize() async {
    PhoneState.stream.listen((event) {
      if (event == PhoneStateStatus.CALL_STARTED) {
        var result = {"final_confidence": 0.85}; // Example scam detection confidence
        onScamDetected(result);
      }
    });
  }

  Future<void> startMonitoring() async {
    print("Call monitoring started...");
  }

  Future<void> stopMonitoring() async {
    print("Call monitoring stopped...");
  }

  void dispose() {
    print("CallMonitor disposed.");
  }
}

class _AudioAnalyzerScreenState extends State<AudioAnalyzerScreen> {
  List<AudioJob> _jobs = [];
  bool _isProcessing = false;
  bool _isMonitoring = false;
  CallMonitor? _callMonitor;

  @override
  void initState() {
    super.initState();
    _initializeCallMonitor();
  }

  Future<void> _initializeCallMonitor() async {
    _callMonitor = CallMonitor(
      onScamDetected: (result) {
        _showScamAlert(result);
      },
    );
    await _callMonitor!.initialize();
  }

  void _showScamAlert(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Potential Scam Detected!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Warning: Suspicious activity detected in the current call.'),
            SizedBox(height: 8),
            Text('Confidence: ${(result['final_confidence'] * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('End Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scam Audio Analyzer'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Real-time Call Monitoring'),
            subtitle: Text(_isMonitoring 
              ? 'Monitoring active - Analyzing every 30 seconds' 
              : 'Monitoring inactive'),
            value: _isMonitoring,
            onChanged: (value) async {
              if (value) {
                await _callMonitor?.startMonitoring();
              } else {
                await _callMonitor?.stopMonitoring();
              }
              setState(() {
                _isMonitoring = value;
              });
            },
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
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

  Widget _buildJobCard(AudioJob job) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    child: ListTile(
      leading: Icon(Icons.audiotrack, color: Colors.blue),
      title: Text(job.fileName, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Status: ${job.status}"),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          setState(() {
            _jobs.remove(job);
          });
        },
      ),
    ),
  );
}

  @override
  void dispose() {
    _callMonitor?.dispose();
    super.dispose();
  }
}
