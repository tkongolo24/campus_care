import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/incident_provider.dart';

class StaffIncidentDetailsScreen extends StatefulWidget {
  final Incident incident;

  const StaffIncidentDetailsScreen({
    super.key,
    required this.incident,
  });

  @override
  State<StaffIncidentDetailsScreen> createState() =>
      _StaffIncidentDetailsScreenState();
}

class _StaffIncidentDetailsScreenState
    extends State<StaffIncidentDetailsScreen> {
  late String selectedStatus;
  bool isUpdating = false;

  final List<String> statuses = [
    'pending',
    'under review',
    'resolved',
  ];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.incident.status;
  }

  Future<void> updateStatus() async {
    setState(() {
      isUpdating = true;
    });

    final success = await context
        .read<IncidentProvider>()
        .updateIncidentStatus(
          incidentId: widget.incident.id,
          status: selectedStatus,
        );

    if (!mounted) return;

    setState(() {
      isUpdating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Incident status updated.'
              : 'Could not update incident status.',
        ),
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Incident'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.incident.category,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.incident.description),
            const SizedBox(height: 20),
            const Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.incident.location),
            const SizedBox(height: 24),
            const Text(
              'Update Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                );
              }).toList(),
              onChanged: isUpdating
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          selectedStatus = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUpdating ? null : updateStatus,
                child: isUpdating
                    ? const CircularProgressIndicator()
                    : const Text('Save Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}