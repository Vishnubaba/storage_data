import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp( const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String myTitle = "Хранение данных в файле";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: myTitle,
      home: Scaffold(
        body: MyStatefulDataWidget(title: myTitle, storage: CounterStorage()),
      ),
    );
  }
}
class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }
  Future<int> readCounter() async {
    try{
      final file = await _localFile;
      final contents = await file.readAsString();
      return int.parse(contents);
    } catch(e) {
      return 0;
    }
  }
  Future<File> writeCounter(int counter) async {
    final file = await _localFile;
    return file.writeAsString('$counter');
  }
}
class MyStatefulDataWidget extends StatefulWidget {
  const MyStatefulDataWidget({Key? key, required this.title, required this.storage}) : super(key: key);
  final String title;
  final CounterStorage storage;
  @override
  _MyStatefulDataWidgetState createState() => _MyStatefulDataWidgetState();
}
class _MyStatefulDataWidgetState extends State<MyStatefulDataWidget> {
  int _counter1 = 0; //Shared preferences counter
  int _counter2 = 0; //File counter
  @override
  void initState() {
    super.initState();
    _loadCounter();
    widget.storage.readCounter().then((int value) {
      setState(() {
        _counter2 = value;
      });
    });
  }
  void _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter1 = (prefs.getInt('counter') ?? 0);
    });
  }
  void _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter1 = (prefs.getInt('counter') ?? 0)+1;
      prefs.setInt('counter', _counter1);
    });
  }
  Future<File> _incrementCounter2() {
    setState(() {
      _counter2++;
    });
    return widget.storage.writeCounter(_counter2);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Totalizer1\n (Shared Preferences):"),
              Row(

                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                        onPressed: _incrementCounter,
                        child: const Icon(Icons.add)
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                  Expanded(
                      flex: 1,
                      child: Text('$_counter1', style: Theme.of(context).textTheme.headline5)),
                ],
              ),
              const SizedBox(
                height: 100,
              ),
              const Text("Totalizer2\n (Text File):"),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                        onPressed: _incrementCounter2,
                        child: const Icon(Icons.add)
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                  Expanded(
                      flex: 1,
                      child: Text('$_counter2', style: Theme.of(context).textTheme.headline5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}