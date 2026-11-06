
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
        return Colors.orange.shade800;
      default:
        return Colors.blue;
    }
  }

  String _formatDate() {
    if (incident.createdAt == null) {
      return 'Date unavailable';
    }

    final date = incident.createdAt!.toDate().toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year at $hour:$minute';
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool selectable = false,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.indigo, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  selectable
                      ? SelectableText(
                          value,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                          ),
                        )
                      : Text(
                          value,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final photoUrl = incident.photoUrl;

    if (photoUrl == null || photoUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Attached Photo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            photoUrl,
            width: double.infinity,
            height: 230,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;

              return const SizedBox(
                height: 230,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Text(
                  'Unable to load attached photo.',
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(incident.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFFE0E4FA),
                    child: Icon(
                      Icons.report_problem_outlined,
                      color: Colors.indigo,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    incident.category,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      incident.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Report Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _buildInfoCard(
              icon: Icons.description_outlined,
              title: 'Description',
              value: incident.description,
            ),

            _buildInfoCard(
              icon: Icons.location_on_outlined,
              title: 'Location',
              value: incident.location,
            ),

            _buildPhotoSection(),

            _buildInfoCard(
              icon: Icons.calendar_today_outlined,
              title: 'Submitted',
              value: _formatDate(),
            ),

            _buildInfoCard(
              icon: Icons.tag,
              title: 'Report ID',
              value: incident.id,
              selectable: true,
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.indigo,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your report is being handled by campus '
                      'staff. You can check My Reports to see '
                      'any status updates.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
