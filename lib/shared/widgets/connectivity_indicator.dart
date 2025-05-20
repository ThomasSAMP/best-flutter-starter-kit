import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/services/connectivity_service.dart';

class ConnectivityIndicator extends StatefulWidget {
  const ConnectivityIndicator({super.key});

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator>
    with SingleTickerProviderStateMixin {
  final _connectivityService = getIt<ConnectivityService>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _connectivityService.connectionStatus.listen(_handleConnectivityChange);

    // Vérifier l'état initial
    _updateVisibility(_connectivityService.currentStatus == ConnectionStatus.offline);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleConnectivityChange(ConnectionStatus status) {
    _updateVisibility(status == ConnectionStatus.offline);
  }

  void _updateVisibility(bool shouldBeVisible) {
    if (_isVisible != shouldBeVisible) {
      setState(() {
        _isVisible = shouldBeVisible;
      });

      if (_isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Visibility(
          visible: _animation.value > 0,
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              color: Colors.red.shade700,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Vous êtes hors ligne',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
