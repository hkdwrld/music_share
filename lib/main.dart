import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:music_share/firebase_options.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.blueAccent,
    ),
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(YoutubePlayerDemoApp());
}

/// Creates [YoutubePlayerDemoApp] widget.
class YoutubePlayerDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Youtube Player Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          color: Colors.blueAccent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.blueAccent,
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = YoutubePlayerController(
    params: YoutubePlayerParams(
      mute: false,
      showControls: false,
      showFullscreenButton: true,
    ),
  );

  final TextEditingController _textEditingController = TextEditingController();
  FirebaseDatabase database = FirebaseDatabase.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.loadVideoById(videoId: 'pnJriqNxpcc');
    _controller.mute();
    _controller.playVideo();
    // _controller.unMute();
    // _controller.seekTo(
    //   seconds: 10,
    //   allowSeekAhead: true,
    // );
    Future.delayed(const Duration(seconds: 1), () => "1");
    // _controller.unMute();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference starCountRef = FirebaseDatabase.instance.ref('song');
    starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      print(data);
      _controller.loadVideoById(videoId: data.toString());
      // _controller.unMute();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Youtube Player Flutter'),
      ),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          ),
          ElevatedButton(
            onPressed: () async {
              _controller.currentTime.then((value) {
                _controller.seekTo(
                  seconds: value + 10,
                  allowSeekAhead: true,
                );
              });
            },
            child: Text("Forward 10 seconds"),
          ),
          TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(hintText: "Enter video id"),
            onSubmitted: (value) {
              starCountRef.set(value);
              _controller.loadVideoById(videoId: value);
            },
          ),
          ElevatedButton(
            onPressed: () {
              _controller.unMute();
            },
            child: const Text("Unmute"),
          ),
        ],
      ),
    );
  }
}
