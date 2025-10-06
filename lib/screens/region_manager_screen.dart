import 'package:enviro_agri_manager/models/region.dart';
import 'package:enviro_agri_manager/providers/region_provider.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegionManagerScreen extends StatefulWidget {
  const RegionManagerScreen({super.key});

  @override
  State<RegionManagerScreen> createState() => _RegionManagerScreenState();
}

class _RegionManagerScreenState extends State<RegionManagerScreen> {
  late List<Region> regions;
  @override
  void initState() {
    regions = context.read<RegionProvider>().regions;
    super.initState();
  }

  // Map id region -> isExpanded
  final Map<String, bool> _expanded = {};

  List<Region> getChildren(String? parentId) =>
      regions.where((r) => r.parentId == parentId).toList();

  // Build tree recursively
  List<Widget> buildRegionTree(String? parentId, int level) {
    final children = getChildren(parentId);
    List<Widget> widgets = [];

    for (var child in children) {
      final hasChildren = getChildren(child.id).isNotEmpty;
      final isExpanded = _expanded[child.id] ?? false;

      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: level * 20.0),
          child: InkWell(
            onTap: () {
              if (hasChildren) {
                setState(() {
                  _expanded[child.id] = !isExpanded;
                });
              }
            },
            child: ListTile(
              leading: hasChildren
                  ? Icon(isExpanded ? Icons.expand_less : Icons.expand_more)
                  : const SizedBox(width: 40),
              title: Text(
                child.name,
                style: TextStyle(
                  fontSize: 16 - level * 1.5,
                  fontWeight: level == 0 ? FontWeight.bold : FontWeight.normal,
                  color: level == 0
                      ? Colors.blue
                      : (level == 1 ? Colors.green : Colors.black),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  RoleBasedActionButton(
                    permission: 'edit',
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {
                        // Handle edit action
                      },
                    ),
                  ),
                  RoleBasedActionButton(
                    permission: 'delete',
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.orange),
                      onPressed: () {
                        // Handle edit action
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (hasChildren && isExpanded) {
        widgets.addAll(buildRegionTree(child.id, level + 1));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Các vị trí hoạt động')),
      body: ListView(children: buildRegionTree(null, 0)),
      floatingActionButton: RoleBasedActionButton(
        permission: 'edit',
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF5E81AC),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
