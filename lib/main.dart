import 'package:flutter/material.dart';
import 'dart:math';
import 'database_helper.dart';  

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> {
  List<Fish> fishList = [];
  Color selectedColor = Colors.blue; 
  double selectedSpeed = 1.0;
  List<Map<String, dynamic>> savedSettings = []; 
  String? selectedSave; 
  int? selectedSaveId;  

  @override
  void initState() {
    super.initState();
    _loadSavedSettingsList();
  }

  _loadSavedSettingsList() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> settingsList = await dbHelper.loadSettingsList();

    setState(() {
      savedSettings = settingsList;
    });

    print('Loaded settings: $savedSettings');
  }

  Future<void> _showSaveDialog() async {
    TextEditingController saveController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Save Name'),
          content: TextField(
            controller: saveController,
            decoration: InputDecoration(hintText: "Save Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  selectedSave = saveController.text;
                });
                _savePreferences(); 
                Navigator.of(context).pop(); 
              },
            ),
          ],
        );
      },
    );
  }

  _savePreferences() async {
    if (selectedSave == null || selectedSave!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a name for the save!')),
      );
      return;
    }

    DatabaseHelper dbHelper = DatabaseHelper.instance;

    try {
      int result = await dbHelper.saveSettings(
        selectedSave!,       
        selectedColor.value,  
        selectedSpeed,        
        fishList.length,      
      );

      if (result > 0) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Settings saved successfully!'))
        );
      } else {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings. Please try again.'))
        );
      }

      
      _loadSavedSettingsList();
    } catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e'))
      );
    }
  }

  _loadPreferences(int id) async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    Map<String, dynamic>? settings = await dbHelper.loadSettingsById(id);

    if (settings != null) {
      setState(() {
        selectedColor = Color(settings['color']);
        selectedSpeed = settings['speed'];
        int fishCount = settings['fish_count'];
        fishList.clear();
        for (int i = 0; i < fishCount; i++) {
          fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Aquarium'),
      ),
      body: SingleChildScrollView(  
        child: Column(
          children: [
            SizedBox(
              width: 200,  
              height: 300,
              child: Container(
                color: Colors.lightBlueAccent,
                child: Stack(
                  children: fishList
                      .map((fish) => AnimatedFish(fish: fish, containerWidth: 200, containerHeight: 300))
                      .toList(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: addFish,
                  child: Text('Add Fish'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: removeFish,  
                  child: Text('Remove Fish'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Speed:'),
                Slider(
                  value: selectedSpeed,
                  min: 0.5,
                  max: 3.0,
                  divisions: 5,
                  label: selectedSpeed.toString(),
                  onChanged: (value) {
                    setState(() {
                      selectedSpeed = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Color:'),
                DropdownButton<Color>(
                  value: selectedColor,
                  onChanged: (Color? newColor) {
                    setState(() {
                      if (newColor != null) {
                        selectedColor = newColor;
                      }
                    });
                  },
                  items: [
                    DropdownMenuItem<Color>(
                      value: Colors.blue,
                      child: Container(
                        width: 24,
                        height: 24,
                        color: Colors.blue,
                      ),
                    ),
                    DropdownMenuItem<Color>(
                      value: Colors.red,
                      child: Container(
                        width: 24,
                        height: 24,
                        color: Colors.red,
                      ),
                    ),
                    DropdownMenuItem<Color>(
                      value: Colors.green,
                      child: Container(
                        width: 24,
                        height: 24,
                        color: Colors.green,
                      ),
                    ),
                    DropdownMenuItem<Color>(
                      value: Colors.yellow,
                      child: Container(
                        width: 24,
                        height: 24,
                        color: Colors.yellow,
                      ),
                    ),
                    DropdownMenuItem<Color>(
                      value: Colors.orange,
                      child: Container(
                        width: 24,
                        height: 24,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _showSaveDialog,
                  child: Text('Save Settings'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  hint: Text("Load Saved Settings"),
                  value: savedSettings.any((save) => save['id'] == selectedSaveId) ? selectedSaveId : null,  
                  onChanged: (int? newId) {
                    setState(() {
                      selectedSaveId = newId;
                      if (selectedSaveId != null) {
                        _loadPreferences(selectedSaveId!);
                      }
                    });
                  },
                  items: savedSettings.map((save) {
                    return DropdownMenuItem<int>(
                      value: save['id'],  
                      child: Text(save['name'] ?? 'Unnamed Save'),  
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void addFish() {
    setState(() {
      fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
    });
  }

  void removeFish() {
    if (fishList.isNotEmpty) {
      setState(() {
        fishList.removeLast();  
      });
    }
  }
}

class Fish {
  final Color color;
  final double speed;

  Fish({required this.color, required this.speed});
}

class AnimatedFish extends StatefulWidget {
  final Fish fish;
  final double containerWidth;
  final double containerHeight;

  AnimatedFish({ required this.fish, required this.containerWidth, required this.containerHeight});

  @override
  _AnimatedFishState createState() => _AnimatedFishState();
}

class _AnimatedFishState extends State<AnimatedFish> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _position;

  Offset currentPosition = Offset(0, 0);
  Offset destination = Offset(0, 0);

  @override
  void initState() {
    super.initState();

    currentPosition = Offset(
      Random().nextDouble() * widget.containerWidth,
      Random().nextDouble() * widget.containerHeight,
    );

    destination = _getRandomPosition();

    _controller = AnimationController(
      duration: Duration(seconds: (5 / widget.fish.speed).round()),
      vsync: this,
    )..forward();

    _position = Tween<Offset>(begin: currentPosition, end: destination)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear))
      ..addListener(() {
        setState(() {});
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _setNewDestination();
      }
    });
  }

  Offset _getRandomPosition() {
    return Offset(
      Random().nextDouble() * (widget.containerWidth - 20), 
      Random().nextDouble() * (widget.containerHeight - 20), 
    );
  }

  void _setNewDestination() {
    setState(() {
      currentPosition = destination;
      destination = _getRandomPosition();
      _position = Tween<Offset>(begin: currentPosition, end: destination)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
      _controller.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.value.dx,
      top: _position.value.dy,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: widget.fish.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
