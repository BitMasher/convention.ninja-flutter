import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InventoryAssetModify extends StatefulWidget {
  final String orgId;
  final String? assetId;

  const InventoryAssetModify({Key? key, required this.orgId, this.assetId})
      : super(key: key);

  @override
  State<InventoryAssetModify> createState() => _InventoryAssetModifyState();
}

class _InventoryAssetModifyState extends State<InventoryAssetModify> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 500,
        height: 350,
        child: Card(
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 240,
                    height: 350,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Serial Number'
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            hint: const Text("Manufacturer"),
                            onChanged: (_) {},
                            items: [
                              DropdownMenuItem<String>(value: 'test', child: Text('test')),
                            ]
                          ),
                          DropdownButtonFormField<String>(
                              hint: const Text("Model"),
                              onChanged: (_) {},
                              items: [
                                DropdownMenuItem<String>(value: 'test', child: Text('test')),
                              ]
                          )
                        ]
                      ),
                    ),
                  ),
                  VerticalDivider(),
                  SizedBox(
                  height: 250,
                    width: 230,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        TextFormField(decoration: InputDecoration(hintText: 'Asset Tag')),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text('tag 1'),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: (){}, child: Text('Delete'))))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text('tag 1'),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: (){}, child: Text('Delete'))))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text('tag 1'),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: (){}, child: Text('Delete'))))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text('tag 1'),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: (){}, child: Text('Delete'))))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text('tag 1'),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: (){}, child: Text('Delete'))))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text('tag 1'),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: (){}, child: Text('Delete'))))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text('tag 1'),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: (){}, child: Text('Delete'))))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text('tag 1'),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: (){}, child: Text('Delete'))))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text('tag 1'),
                              Expanded(child: Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: (){}, child: Text('Delete'))))
                            ],
                          ),
                        ),

                      ]
                    ),
                  )
                ]
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(alignment: Alignment.bottomRight, child: ElevatedButton(onPressed: (){}, child: Text('Save'),)),
              )
            ]
          ),
        ),
      )
    );
  }
}
