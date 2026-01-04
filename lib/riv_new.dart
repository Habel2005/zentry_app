import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

void main() => runApp(const MaterialApp(home: ProfileDebugScreen()));

class ProfileDebugScreen extends StatelessWidget {
  const ProfileDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey, // Different color to see if it renders
      appBar: AppBar(title: const Text("Profile Debug")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Testing: assets/riv/avatar.riv", 
              style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white, // White box to see the Artboard bounds
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: RiveAnimation.asset(
                'assets/riv/avatar.riv',
                // Leave artboard blank for the test so it loads the default
                onInit: (artboard) {
                  print("--- PROFILE RIVE SUCCESS ---");
                  print("Artboard Name: ${artboard.name}");
                  
                  if (artboard.stateMachines.isNotEmpty) {
                    print("SM Name: ${artboard.stateMachines.first.name}");
                    for (var input in artboard.stateMachines.first.inputs) {
                      print("Input Found: ${input.name} (${input.runtimeType})");
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}