import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/screens/service_item_form.dart';
import '../providers/service_item_provider.dart';

class ServiceItemListScreen extends ConsumerWidget {
  const ServiceItemListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceItems = ref.watch(serviceItemsProvider);

    return Scaffold(
      body: Row(
        children: [
          /// Left - List
          Expanded(
            flex: 4,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: serviceItems.length,
              itemBuilder: (context, index) {
                final item = serviceItems[index];
                return Card(
                  child: ListTile(
                    title: Text(
                        "Invoice: ${item.invoiceId} - ${item.customerName}"),
                    subtitle: Text(
                        "Model: ${item.model}, Brand: ${item.brand.target?.name ?? ''}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ref
                            .read(serviceItemsProvider.notifier)
                            .deleteItem(item.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const VerticalDivider(),

          /// Right - Form
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: ServiceItemForm(),
            ),
          ),
        ],
      ),
    );
  }
}
