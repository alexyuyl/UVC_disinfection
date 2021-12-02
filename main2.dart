import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';
late List<CameraDescription> cameras;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(
    MaterialApp(
      theme: ThemeData.light(),
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  //final CameraDescription camera;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String actionText = 'Take picture to start disinfecting';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Home Page",
      theme: ThemeData(primarySwatch: Colors.lightBlue,),
      home: Scaffold(
        appBar: AppBar(
            title: const Text('Camera'),
            backgroundColor: Colors.lightGreen,
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async{
              await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TakePictureScreen(
                      //camera: camera,
                    ),
                  )
              );
            },
            child: const Icon(Icons.camera_alt)
        ),
        body: Center(
            child: Center(
              child:
              Text(
                actionText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            )
        ),

      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({Key? key}) : super(key: key);

  //final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}


class TakePictureScreenState extends State<TakePictureScreen> {

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final camera = cameras.first;

  @override
  void initState(){
    super.initState();
    /*availableCameras().then((availableCameras) {
      cameras = availableCameras;
      final camera = cameras.first;
    });*/
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose(){ _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Take a picture')),
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.camera_alt),
          onPressed: () async{
            try{
              await _initializeControllerFuture;
              final image = await _controller.takePicture();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                    imagePath: image.path,
                  ),
                ),
              );
            } catch (e){
              print(e);
            }
          },
        )
    );
  }
}

class DisplayPictureScreen extends StatelessWidget{
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:const Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}
