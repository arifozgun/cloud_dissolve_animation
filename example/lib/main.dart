import 'package:flutter/material.dart';
import 'package:cloud_dissolve_animation/cloud_dissolve_animation.dart';
import 'package:flutter/widget_previews.dart';

void main() => runApp(const MyApp());

@Preview(name: 'Cloud Dissolve App')
Widget cloudDissolveAppPreview() => const MyApp();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cloud Dissolve Example',
      theme: ThemeData.dark(),
      home: const CloudDissolveExample(),
    );
  }
}

class CloudDissolveExample extends StatefulWidget {
  const CloudDissolveExample({super.key});

  @override
  State<CloudDissolveExample> createState() => _CloudDissolveExampleState();
}

class _CloudDissolveExampleState extends State<CloudDissolveExample> {
  final List<_Item> _items = List.generate(
    10,
    (index) => _Item(id: index, title: 'Item ${index + 1}'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Dissolve Example')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return DeletableItemWrapper(
            key: ValueKey(item.id),
            isDeleting: item.isDeleting,
            onDeleteComplete: () {
              setState(() => _items.removeWhere((i) => i.id == item.id));
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.cloud),
                title: Text(item.title),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() => item.isDeleting = true);
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _items.add(_Item(
              id: DateTime.now().millisecondsSinceEpoch,
              title: 'Item ${_items.length + 1}',
            ));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Item {
  final int id;
  final String title;
  bool isDeleting = false;

  _Item({required this.id, required this.title});
}
