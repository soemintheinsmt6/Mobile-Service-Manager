import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_service_manager/constants/app_colors.dart';
import 'package:mobile_service_manager/utils/extension.dart';
import 'package:mobile_service_manager/widgets/revenue_card.dart';
import '../providers/revenue_provider.dart';
import '../utils/date_time_picker.dart';

class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});

  @override
  ConsumerState<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends ConsumerState<RevenueScreen> {
  DateTime? selectedDate;
  DateTime? fromDate;
  DateTime? toDate;
  bool isDateRangeMode = false;

  @override
  void initState() {
    super.initState();

    selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(revenueNotifierProvider.notifier)
          .loadDailyRevenue(selectedDate!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final revenueData = ref.watch(revenueNotifierProvider);
    final revenueNotifier = ref.read(revenueNotifierProvider.notifier);
    final isValidDateRange = fromDate != null && toDate != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Report'),
        backgroundColor: const Color(0xFF4372C4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isDateRangeMode ? Icons.today : Icons.date_range),
            onPressed: () {
              setState(() {
                isDateRangeMode = !isDateRangeMode;
                if (!isDateRangeMode && selectedDate != null) {
                  revenueNotifier.loadDailyRevenue(selectedDate!);
                }
              });
            },
            tooltip: isDateRangeMode ? 'Single Date' : 'Date Range',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      if (!isDateRangeMode) ...[
                        // Single Date Picker
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectDate(context),
                                icon: const Icon(Icons.calendar_today,
                                    color: Colors.black87),
                                label: Text(
                                    selectedDate != null
                                        ? selectedDate.toString().formattedDate
                                        : 'Select Date',
                                    style:
                                        const TextStyle(color: Colors.black87)),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Date Range Picker
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectFromDate(context),
                                icon: const Icon(Icons.calendar_today,
                                    color: Colors.black87),
                                label: Text(
                                  fromDate != null
                                      ? 'From: ${fromDate.toString().formattedDate}'
                                      : 'From Date',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectToDate(context),
                                icon: const Icon(Icons.calendar_today,
                                    color: Colors.black87),
                                label: Text(
                                  toDate != null
                                      ? 'To: ${toDate.toString().formattedDate}'
                                      : 'To Date',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isValidDateRange
                                    ? AppColors.primaryButton
                                    : Colors.grey.shade100,
                                foregroundColor: isValidDateRange
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                if (!isValidDateRange) return;

                                revenueNotifier.loadRevenueForDateRange(
                                    fromDate!, toDate!);
                              },
                              child: const Text('Load Range Data'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Revenue Data Display
            Expanded(
              child: revenueData.isEmpty
                  ? const Center(
                      child: Text(
                        'No data available for selected date(s)',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: revenueData.length,
                      itemBuilder: (context, index) {
                        final revenue = revenueData[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: RevenueCard(revenue: revenue),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDateTimePicker(
      context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      ref.read(revenueNotifierProvider.notifier).loadDailyRevenue(picked);
    }
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDateTimePicker(
      context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDateTimePicker(
      context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: fromDate ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        toDate = picked;
      });
    }
  }
}
