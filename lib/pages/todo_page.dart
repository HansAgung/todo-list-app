import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_app/provider/todo_provider.dart';
import 'package:todo_list_app/widgets/notification.dart';
import '../widgets/todo_item.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TodoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do App'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: prov.loading
                ? null
                : () async {
                    await prov.fetchFromApi(); 
                    if (prov.notificationMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(prov.notificationMessage!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.refresh),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: prov.setQuery,
              decoration: InputDecoration(
                hintText: 'Cari tugas berdasarkan nama…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (prov.loading) const LinearProgressIndicator(),

          // Error banner
          if (prov.error != null)
            MaterialBanner(
              content: Text(prov.error!),
              leading: const Icon(Icons.error_outline),
              actions: [
                TextButton(
                  onPressed: () async {
                    await prov.fetchFromApi(); // ❌ hapus context
                    if (prov.notificationMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(prov.notificationMessage!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('COBA LAGI'),
                )
              ],
            ),

          // Notifikasi offline / warn
          if (prov.notificationMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: NotificationBanner(
                message: prov.notificationMessage!,
                type: NotificationType.warn,
              ),
            ),

          // FutureBuilder + ListView
          Expanded(
            child: FutureBuilder<List>(
              future: context.read<TodoProvider>().initAndFetch(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting &&
                    prov.todos.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = prov.filtered;
                if (list.isEmpty) {
                  return const Center(child: Text('Tidak ada tugas'));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final todo = list[i];
                    return TodoItem(
                      todo: todo,
                      onToggle: (v) => prov.toggle(todo, v),
                      onDelete: () => prov.remove(todo),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 0),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addController,
                      onSubmitted: (_) => _submit(context),
                      decoration: InputDecoration(
                        hintText: 'Tugas baru…',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed:
                        prov.loading ? null : () => _submit(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    final text = _addController.text.trim();
    if (text.isEmpty) return;
    context.read<TodoProvider>().add(text);
    _addController.clear();

    // Tampilkan notifikasi sukses
    final prov = context.read<TodoProvider>();
    prov.notificationMessage = null; // clear offline warning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tugas berhasil ditambahkan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
