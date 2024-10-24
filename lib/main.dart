import 'package:flutter/material.dart';
import 'dart:math';
import 'database_helper.dart';

void main() {
  runApp(myApp());
}

class myApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aquarium',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aquarium'),
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
                      .map((fish) => AnimatedFish(
                            fish: fish,
                            containerWidth: 200,
                            containerHeight: 300,
                          ))
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
          ],
        ),
      ),
    );
  }

  // Add Fish method
  void addFish() {
    setState(() {
      fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
    });
  }

  // Remove Fish method
  void removeFish() {
    if (fishList.isNotEmpty) {
      setState(() {
        fishList.removeLast();  // Remove the last fish added
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

  AnimatedFish({required this.fish, required this.containerWidth, required this.containerHeight});

  @override
  _AnimatedFishState createState() => _AnimatedFishState();
}

class _AnimatedFishState extends State<AnimatedFish> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<Offset> _position;

  Offset currentPosition = Offset(0, 0);
  Offset destination = Offset(0, 0);

  @override
  void initState() {
    super.initState();
    
    currentPosition = Offset(
      Random.nextDouble() * widget.containerWidth,
      Random.nextDouble() * widget.containerHeight,
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
        Random.nextDouble() * (widget.containerWidth - 20),
        Random.nextDouble() * (widget.containerHeight - 20),
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
        top = _position.value.dy,
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
    }

}