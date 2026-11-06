
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import 'incident_details_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  late Stream<List<Incident>> _reportsStream;

  String _selectedStatus = 'All';
  String _searchQuery = '';

  final List<String> _statuses = [
    'All',
    'Pending',
    'Under Review',
    'Resolved',
  ];

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().user!;

    _reportsStream = context
        .read<IncidentProvider>()
        .getUserIncidents(user.uid);
  }

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
        title: const Text('My Reports'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search reports',
                    hintText: 'Search by category, description or location',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Filter by status',
                    border: OutlineInputBorder(),
                  ),
                  items: _statuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Incident>>(
              stream: _reportsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load your reports.'),
                  );
                }

                final reports = snapshot.data ?? [];

                final filteredReports = reports.where((report) {
                  final matchesStatus =
                      _selectedStatus == 'All' ||
                      report.status.toLowerCase() ==
                          _selectedStatus.toLowerCase();

                  final matchesSearch =
                      report.category.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                      report.description.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                      report.location.toLowerCase().contains(
                            _searchQuery,
                          );

                  return matchesStatus && matchesSearch;
                }).toList();

                if (filteredReports.isEmpty) {
                  return const Center(
                    child: Text('No matching reports found.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  IncidentDetailsScreen(
                                incident: report,
                              ),
                            ),
                          );
                        },
                        leading: const CircleAvatar(
                          child: Icon(Icons.report_problem),
                        ),
                        title: Text(report.category),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(report.description),
                            const SizedBox(height: 4),
                            Text('Location: ${report.location}'),
                            const SizedBox(height: 8),
                            Text(
                              report.status.toUpperCase(),
                              style: TextStyle(
                                color: _statusColor(report.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
