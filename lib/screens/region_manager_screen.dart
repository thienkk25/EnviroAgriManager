import 'package:enviro_agri_manager/models/region.dart';
import 'package:enviro_agri_manager/providers/region_provider.dart';
import 'package:enviro_agri_manager/widgets/role_based_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

enum RegionDialogMode { add, edit }

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

  Future<void> reset() async {
    await context.read<RegionProvider>().fetchRegions();
    setState(() {
      regions = context.read<RegionProvider>().regions;
    });
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
                        showRegionDialog(
                          context: context,
                          mode: RegionDialogMode.edit,
                          region: child,
                        );
                      },
                    ),
                  ),
                  RoleBasedActionButton(
                    permission: 'delete',
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.orange),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text(
                              'Bạn có chắc chắn muốn xóa khu vực "${child.name}" không?'
                              ' ${hasChildren ? "Tất cả các khu vực con cũng sẽ bị xóa." : ""}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await context
                                      .read<RegionProvider>()
                                      .deleteRegion(child.id);
                                  if (!context.mounted) return;
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result ? 'Xóa thành công' : 'Có lỗi!',
                                        style: GoogleFonts.inter(),
                                      ),
                                      backgroundColor: result
                                          ? const Color(0xFFA3BE8C)
                                          : Colors.red,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );
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
      appBar: AppBar(title: const Text('Các địa điểm hoạt động')),
      body: Consumer<RegionProvider>(
        builder: (context, regionProvider, child) {
          if (regionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (regionProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    regionProvider.error,
                    style: GoogleFonts.inter(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => regionProvider.fetchRegions(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final regions = regionProvider.getMainRegions();

          if (regions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có vị trí nào',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm vị trí để bắt đầu',
                    style: GoogleFonts.inter(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          return ListView(children: buildRegionTree(null, 0));
        },
      ),
      floatingActionButton: RoleBasedActionButton(
        permission: 'edit',
        child: FloatingActionButton(
          onPressed: () {
            showRegionDialog(context: context, mode: RegionDialogMode.add);
          },
          backgroundColor: const Color(0xFF5E81AC),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> showRegionDialog({
    required BuildContext context,
    required RegionDialogMode mode,
    Region? region,
  }) async {
    final nameController = TextEditingController(text: region?.name ?? '');
    final descriptionController = TextEditingController(
      text: region?.description ?? '',
    );

    bool isAdd = mode == RegionDialogMode.add;
    bool isActive = region?.isActive ?? true;
    String? selectedLocationFirstLevel;

    String? selectedLocationSecondLevel;

    String? newParentId;

    if (!isAdd) {
      nameController.text = region!.name;
      final getRegionIds = context.read<RegionProvider>().getRegionIds(
        region.id,
      );
      selectedLocationFirstLevel = getRegionIds.isNotEmpty
          ? getRegionIds[0]
          : null;
      selectedLocationSecondLevel = getRegionIds.length > 1
          ? getRegionIds[1]
          : null;
      if (getRegionIds.length == 1) {
        newParentId = null;
      } else if (getRegionIds.length == 2) {
        newParentId = selectedLocationFirstLevel;
      } else {
        newParentId = selectedLocationSecondLevel;
      }
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, StateSetter stateSetter) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                !isAdd ? 'Chỉnh sửa khu vực' : 'Thêm khu vực mới',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    const Text('Tên khu vực'),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Nhập tên khu vực...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const Text('Thuộc khu vực cấp nhất (nếu có)'),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      initialValue: selectedLocationFirstLevel,
                      hint: const Text('Chọn khu vực cấp nhất'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Không có (cấp cao nhất)'),
                        ),
                        ...context.read<RegionProvider>().getMainRegions().map(
                          (region) => DropdownMenuItem<String>(
                            value: region.id,
                            child: Text(region.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        stateSetter(() {
                          selectedLocationFirstLevel = value;
                          selectedLocationSecondLevel = null;
                          if (!isAdd) {
                            newParentId = value;
                          }
                        });
                      },
                    ),
                    if (selectedLocationFirstLevel != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Thuộc khu vực cấp nhì (nếu có)'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            initialValue: selectedLocationSecondLevel,
                            hint: const Text('Chọn khu vực cấp nhì'),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Không có (cấp cao nhì)'),
                              ),
                              ...context
                                  .read<RegionProvider>()
                                  .getSubRegions(selectedLocationFirstLevel!)
                                  .map(
                                    (region) => DropdownMenuItem<String>(
                                      value: region.id,
                                      child: Text(region.name),
                                    ),
                                  ),
                            ],
                            onChanged: (value) {
                              stateSetter(() {
                                selectedLocationSecondLevel = value;
                                if (!isAdd) {
                                  if (value == null) {
                                    newParentId = selectedLocationFirstLevel;
                                  } else {
                                    newParentId = value;
                                  }
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    const Text('Trạng thái'),
                    DropdownButtonFormField(
                      initialValue: isActive,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: true, child: Text("Hoạt động")),
                        DropdownMenuItem(value: false, child: Text("Tạm dừng")),
                      ],
                      onChanged: (value) {
                        isActive = value!;
                      },
                    ),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(isAdd ? 'Thêm' : 'Lưu'),
                  onPressed: () async {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập tên khu vực'),
                        ),
                      );
                      return;
                    }

                    if (isAdd) {
                      final newRegion = Region(
                        id: Uuid().v4(),
                        name: nameController.text,
                        description: descriptionController.text,
                        isActive: isActive,
                        parentId:
                            selectedLocationSecondLevel ??
                            selectedLocationFirstLevel,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      final result = await context
                          .read<RegionProvider>()
                          .addRegion(newRegion);
                      if (!context.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result ? 'Đã thêm vị trí thành công' : 'Có lỗi!',
                            style: GoogleFonts.inter(),
                          ),
                          backgroundColor: result
                              ? const Color(0xFFA3BE8C)
                              : Colors.red,
                        ),
                      );
                    } else {
                      final newRegion = region!.copyWith(
                        name: nameController.text,
                        description: descriptionController.text,
                        isActive: isActive,
                        parentId: newParentId,
                        updatedAt: DateTime.now(),
                      );
                      bool result = false;

                      if (selectedLocationFirstLevel == null) {
                        result = await context
                            .read<RegionProvider>()
                            .updateRegion(newRegion, true);
                        await reset();
                      } else {
                        result = await context
                            .read<RegionProvider>()
                            .updateRegion(newRegion, false);
                      }

                      if (!context.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result
                                ? 'Đã cập nhật vị trí thành công'
                                : 'Có lỗi!',
                            style: GoogleFonts.inter(),
                          ),
                          backgroundColor: result
                              ? const Color(0xFFA3BE8C)
                              : Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
