/// Medication List Screen
library;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/medication_provider.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});
  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<MedicationProvider>(context, listen: false).fetchReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => context.push('/add-medication')),
        ],
      ),
      body: Consumer<MedicationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());

          if (provider.reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.medication_rounded, size: 56, color: AppTheme.accentOrange),
                  ),
                  const SizedBox(height: 20),
                  Text('No Medications', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Add your medications to get reminders', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/add-medication'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Medication'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.reminders.length,
            itemBuilder: (context, index) {
              final med = provider.reminders[index];
              return _MedicationCard(
                medication: med,
                onTaken: () => provider.logMedication(med.id, 'taken').then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${med.medicationName} marked as taken ✓'), backgroundColor: AppTheme.accentGreen),
                  );
                }),
                onSkipped: () => provider.logMedication(med.id, 'skipped'),
                onDelete: () => provider.deleteReminder(med.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-medication'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final dynamic medication;
  final VoidCallback onTaken;
  final VoidCallback onSkipped;
  final VoidCallback onDelete;

  const _MedicationCard({
    required this.medication,
    required this.onTaken,
    required this.onSkipped,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.accentOrange, AppTheme.accentOrange.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.medication, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medication.medicationName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${medication.dosage} • ${medication.frequencyDisplay}', style: Theme.of(context).textTheme.bodySmall),
                      if (medication.instructions != null && medication.instructions!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(medication.instructions!, style: TextStyle(fontSize: 12, color: AppTheme.accentBlue, fontStyle: FontStyle.italic)),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: AppTheme.lightText),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Remove')])),
                  ],
                  onSelected: (v) { if (v == 'delete') onDelete(); },
                ),
              ],
            ),
          ),
          // Schedule times
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppTheme.lightText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    medication.times.map((t) => t.toString().substring(0, 5)).join(', '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                // Quick action buttons
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: onTaken,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Taken', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: onSkipped,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Skip', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
