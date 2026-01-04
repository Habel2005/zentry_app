import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

void main() => runApp(const MaterialApp(home: ProfileAnimationTest()));

class ProfileAnimationTest extends StatefulWidget {
  const ProfileAnimationTest({super.key});

  @override
  _ProfileAnimationTestState createState() => _ProfileAnimationTestState();
}

class _ProfileAnimationTestState extends State<ProfileAnimationTest> {
  // Use unique names to avoid any mixups
  SMITrigger? _testPressed;
  SMIBool? _testHover;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(title: const Text("Profile Animation Debug")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Tap the Icon to Trigger 'Pressed'",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                if (_testPressed != null) {
                  print("Firing 'Pressed' trigger now...");
                  _testPressed!.fire();
                } else {
                  print("Error: Trigger not found yet!");
                }
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: RiveAnimation.asset(
                    'assets/riv/avatar.riv',
                    artboard: 'New Artboard',
                    fit: BoxFit.contain, // Keep it simple for the test
                    onInit: (artboard) {
                      final controller = StateMachineController.fromArtboard(
                        artboard,
                        'State Machine 1',
                      );
                      if (controller != null) {
                        artboard.addController(controller);
                        
                        // Debug prints to confirm existence
                        _testHover = controller.findInput<bool>('Hover') as SMIBool?;
                        _testPressed = controller.findSMI('Pressed') as SMITrigger?;
                        
                        print("--- DEBUG RESULTS ---");
                        print("Hover Input found: ${_testHover != null}");
                        print("Pressed Trigger found: ${_testPressed != null}");
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Manually toggle hover to see if it changes state
                if (_testHover != null) {
                  _testHover!.value = !_testHover!.value;
                  print("Hover value toggled to: ${_testHover!.value}");
                }
              },
              child: const Text("Toggle Hover State"),
            )
          ],
        ),
      ),
    );
  }
}