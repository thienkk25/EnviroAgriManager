import 'package:flutter/material.dart';

class CateoryTree extends StatefulWidget {
  const CateoryTree({super.key});

  @override
  State<CateoryTree> createState() => _CateoryTreeState();
}

class _CateoryTreeState extends State<CateoryTree> {
  final Map<String, bool> _expanded = {};
  List<Widget> buildCategoryTree(String id, int level) {
    List<Widget> widgets = [];

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
