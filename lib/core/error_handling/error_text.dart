import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String errorText;

  const ErrorText({super.key, required this.errorText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SelectableText(
        errorText,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 16.0,
        ),
        showCursor: true,
        cursorColor: Colors.blue,
        toolbarOptions: const ToolbarOptions(
          copy: true,
          selectAll: true,
        ),
      ),
    );
  }
}
