/// Appointment List Screen
library;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/appointment_provider.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});
  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Provider.of<AppointmentProvider>(context, listen: false).fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push('/book-appointment'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.lightText,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(provider.appointments),
              _buildList(provider.appointments.where((a) => a.status == 'pending' || a.status == 'confirmed').toList()),
              _buildList(provider.appointments.where((a) => a.status == 'completed').toList()),
              _buildList(provider.appointments.where((a) => a.status == 'cancelled').toList()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/book-appointment'),
        icon: const Icon(Icons.add),
        label: const Text('Book'),
      ),
    );
  }

  Widget _buildList(List appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: AppTheme.lightText),
            const SizedBox(height: 16),
            Text('No appointments found', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final apt = appointments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.accentBlue.withOpacity(0.1),
                    child: Icon(Icons.person, color: AppTheme.accentBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(apt.doctorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(apt.typeDisplay, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  _StatusBadge(status: apt.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppTheme.lightText),
                  const SizedBox(width: 6),
                  Text(apt.appointmentDate, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 14, color: AppTheme.lightText),
                  const SizedBox(width: 6),
                  Text(apt.appointmentTime.substring(0, 5), style: Theme.of(context).textTheme.bodySmall),
                  if (apt.hospitalName.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.local_hospital, size: 14, color: AppTheme.lightText),
                    const SizedBox(width: 6),
                    Expanded(child: Text(apt.hospitalName, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                  ],
                ],
              ),
              if (apt.reason != null) ...[
                const SizedBox(height: 8),
                Text('Reason: ${apt.reason}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'confirmed': color = AppTheme.accentGreen; break;
      case 'completed': color = AppTheme.accentBlue; break;
      case 'cancelled': color = AppTheme.accentRed; break;
      case 'in_progress': color = AppTheme.accentPurple; break;
      default: color = AppTheme.accentOrange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' ').split(' ').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' '),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
