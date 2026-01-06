import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveRefreshIndicator extends StatefulWidget {
  final Widget child;
  final RefreshCallback onRefresh;
  final String riveAnimationPath;

  const RiveRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.riveAnimationPath,
  });

  @override
  State<RiveRefreshIndicator> createState() => _RiveRefreshIndicatorState();
}

class _RiveRefreshIndicatorState extends State<RiveRefreshIndicator> {
  // Rive Controller Inputs
  StateMachineController? _riveController;
  SMINumber? _progressInput;
  SMIBool? _downloadingInput;

  // CONFIGURATION
  final double _indicatorSize = 100.0; 
  final double _refreshTriggerPullDistance = 140.0; 

  void _onRiveInit(Artboard artboard) {
    _riveController = StateMachineController.fromArtboard(artboard, "State machine 1");
    if (_riveController != null) {
      artboard.addController(_riveController!);
      _progressInput = _riveController!.findInput<double>('Progress') as SMINumber?;
      _downloadingInput = _riveController!.findInput<bool>('Downloading') as SMIBool?;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Background color to make the white animation visible in Light Mode
    final Color circleBackgroundColor = isDarkMode 
        ? const Color(0xFF2C2C2E) 
        : const Color(0xFF1A1A1A); 

    return CustomRefreshIndicator(
      onRefresh: widget.onRefresh,
      offsetToArmed: _refreshTriggerPullDistance,
      builder: (context, child, controller) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            
            // --- LOGIC FIX: TRIGGER ANIMATION DURING PULL ---
            if (controller.isDragging || controller.isArmed) {
               // FIX: We set Downloading to TRUE immediately. 
               // This forces the Rive file to exit 'Idle' (Arrow) and enter 'Water' (Liquid).
               _downloadingInput?.value = true;
               
               // Now that we are in the 'Water' state, this Progress value will visually fill the circle.
               _progressInput?.value = (controller.value * 100).clamp(0.0, 100.0);
            } 
            else if (controller.isLoading) {
               _downloadingInput?.value = true;
               _progressInput?.value = 100.0;
            } 
            else {
               // Reset when the refresh is totally done/idle
               _downloadingInput?.value = false;
               _progressInput?.value = 0.0;
            }
            // ------------------------------------------------

            return Stack(
              children: [
                // 1. DASHBOARD CONTENT (Moves down)
                Transform.translate(
                  offset: Offset(0, (_refreshTriggerPullDistance + 20) * controller.value),
                  child: child,
                ),

                // 2. RIVE ANIMATION
                if (controller.value > 0)
                  Positioned(
                    top: 60, 
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Opacity(
                        // This handles the smooth appearance.
                        // Since we force "Downloading=true" instantly, this fade-in 
                        // stops it from looking like a glitchy pop.
                        opacity: (controller.value * 2.0).clamp(0.0, 1.0),
                        child: Container(
                          width: _indicatorSize,
                          height: _indicatorSize,
                          decoration: BoxDecoration(
                            color: circleBackgroundColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(160, 0, 0, 0).withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(15.0),
                          child: RiveAnimation.asset(
                            widget.riveAnimationPath,
                            onInit: _onRiveInit,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
      child: widget.child,
    );
  }
}