import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_service_manager/constants/app_colors.dart';
import 'package:mobile_service_manager/utils/extension.dart';
import '../models/daily_revenue.dart';
import '../providers/revenue_provider.dart';

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
    // Load today's data initially
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection Section
            Card(
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
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                selectedDate != null
                                    ? DateFormat('MMM dd, yyyy')
                                        .format(selectedDate!)
                                    : 'Select Date',
                              ),
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
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                fromDate != null
                                    ? 'From: ${DateFormat('MMM dd, yyyy').format(fromDate!)}'
                                    : 'From Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _selectToDate(context),
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                toDate != null
                                    ? 'To: ${DateFormat('MMM dd, yyyy').format(toDate!)}'
                                    : 'To Date',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (fromDate != null && toDate != null)
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              revenueNotifier.loadRevenueForDateRange(
                                  fromDate!, toDate!);
                            },
                            child: const Text('Load Range Data'),
                          ),
                        ),
                    ],
                  ],
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
                        return _buildRevenueCard(revenue, context);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(DailyRevenue revenue, BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and total count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  revenue.formattedDate,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryButton,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryButton,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total: ${revenue.totalServiceItemCount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Counts
            Text(
              'Service Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child:
                      _buildStatusCard('Done', revenue.doneCount, Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusCard(
                      'In Progress', revenue.inProgressCount, Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusCard(
                      'Return', revenue.returnCount, Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location Counts
            Text(
              'Delivery Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                      'In Store', revenue.inStoreCount, Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusCard(
                      'Delivered', revenue.deliveredCount, Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Financial Summary
            Text(
              'Financial Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  _buildFinancialRow(
                      'Total Price', revenue.priceTotal, Colors.green[700]!),
                  const Divider(),
                  _buildFinancialRow(
                      'Total Expense', revenue.expenseTotal, Colors.red[700]!),
                  const Divider(),
                  _buildFinancialRow(
                    'Profit',
                    revenue.profit,
                    revenue.profit >= 0 ? Colors.green[700]! : Colors.red[700]!,
                    isProfit: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String title, int amount, Color color,
      {bool isProfit = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isProfit ? FontWeight.bold : FontWeight.w500,
            fontSize: isProfit ? 16 : 14,
          ),
        ),
        Text(
          '${amount >= 0 ? '+' : ''}${amount.toMMks()}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: isProfit ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
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
    final DateTime? picked = await showDatePicker(
      context: context,
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
    final DateTime? picked = await showDatePicker(
      context: context,
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
