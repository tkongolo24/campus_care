
import 'package:flutter/material.dart';

import '../../models/incident.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final Incident incident;

  const IncidentDetailsScreen({
    super.key,
    required this.incident,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'under review':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              incident.category,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            const Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Chip(
              label: Text(incident.status.toUpperCase()),
              backgroundColor:
                  _statusColor(incident.status).withAlpha(35),
              labelStyle: TextStyle(
                color: _statusColor(incident.status),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(incident.description),

            const SizedBox(height: 20),

            const Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(incident.location),

            const SizedBox(height: 20),

            const Text(
              'Report ID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(incident.id),

            const SizedBox(height: 20),

            const Text(
              'Submitted',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              incident.createdAt == null
                  ? 'Date unavailable'
                  : incident.createdAt!.toDate().toLocal().toString(),
            ),
          ],
        ),
      ),
    );
  }
}
