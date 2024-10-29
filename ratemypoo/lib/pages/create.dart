import 'package:flutter/material.dart';

class CreateWidget extends StatefulWidget {
  const CreateWidget({super.key});

  @override
  State<CreateWidget> createState() => _CreateWidgetState();
}

class _CreateWidgetState extends State<CreateWidget> {

  @override
  Widget build(BuildContext context) {
    return  const Placeholder(
      color: Colors.blue,
    );
  }
}