import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[300],
        boxShadow: [
          BoxShadow(
            color: _isSwitched ? Colors.green : Colors.transparent,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Transform.translate(
        offset: Offset(_isSwitched ? 32 : 0, 0),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
