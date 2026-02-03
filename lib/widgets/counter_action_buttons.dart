import 'package:flutter/material.dart';

class CounterActionButtons extends StatelessWidget {
  final bool isAutoPlayEnabled;
  final VoidCallback onAutoPlayToggle;
  final VoidCallback onUndo;

  const CounterActionButtons({
    super.key,
    required this.isAutoPlayEnabled,
    required this.onAutoPlayToggle,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAutoPlayButton(),
        _buildUndoButton(),
      ],
    );
  }

  Widget _buildAutoPlayButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isAutoPlayEnabled ? Colors.white : Colors.transparent,
        side: const BorderSide(color: Colors.white),
        shape: const CircleBorder(),
        foregroundColor: isAutoPlayEnabled ? Colors.black : Colors.white,
      ),
      onPressed: onAutoPlayToggle,
      child: const Icon(Icons.replay),
    );
  }

  Widget _buildUndoButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        shape: const CircleBorder(),
        foregroundColor: Colors.black,
      ),
      onPressed: onUndo,
      child: const Icon(Icons.undo),
    );
  }
}




