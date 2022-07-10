
import 'package:flutter/material.dart';

import '../services/inventory_service.dart';

class InventoryCategoriesPage extends StatefulWidget {
  const InventoryCategoriesPage({Key? key, required this.orgId}) : super(key: key);
  final String orgId;
  @override
  State<InventoryCategoriesPage> createState() => _InventoryCategoriesPageState();
}

class _InventoryCategoriesPageState extends State<InventoryCategoriesPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<List<Category>> _categories;
  @override
  void initState() {
    super.initState();
    _categories = InventoryService.getCategories(widget.orgId);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Table(
        border: TableBorder.symmetric(inside: const BorderSide(width: 1.0)),
        children: const [
          TableRow(
            children: [
              TableCell(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Id'),
              )),
              TableCell(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Name'),
              )),
              TableCell(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(''),
              ))
            ]
          ),
        ],
      ),
    );
  }
}