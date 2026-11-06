
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import 'staff_incident_details_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() =>
      _StaffDashboardScreenState();
}

class _StaffDashboardScreenState
    extends State<StaffDashboardScreen> {
  late Stream<List<Incident>> _incidentsStream;

  final TextEditingController _searchController =
      TextEditingController();

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

    _incidentsStream = context
        .read<IncidentProvider>()
        .getAllIncidents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  Widget _buildStatCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 10),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(Incident incident) {
    if (incident.createdAt == null) {
      return 'Date unavailable';
    }

    final date = incident.createdAt!.toDate().toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Widget _buildReportCard(Incident incident) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StaffIncidentDetailsScreen(
                incident: incident,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo.withValues(
                  alpha: 0.10,
                ),
                child: const Icon(
                  Icons.report_problem_outlined,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      incident.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            incident.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Submitted: ${_formatDate(incident)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStatusBadge(incident.status),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 55,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'No matching reports found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your search or status filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: StreamBuilder<List<Incident>>(
        stream: _incidentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Could not load incident reports. '
                  'Please check your connection or permissions.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final incidents = snapshot.data ?? [];

          final pendingCount = incidents
              .where((i) => i.status.toLowerCase() == 'pending')
              .length;

          final reviewCount = incidents
              .where(
                (i) => i.status.toLowerCase() == 'under review',
              )
              .length;

          final resolvedCount = incidents
              .where((i) => i.status.toLowerCase() == 'resolved')
              .length;

          final filteredIncidents = incidents.where((incident) {
            final matchesStatus =
                _selectedStatus == 'All' ||
                incident.status.toLowerCase() ==
                    _selectedStatus.toLowerCase();

            final matchesSearch =
                incident.category.toLowerCase().contains(
                      _searchQuery,
                    ) ||
                incident.description.toLowerCase().contains(
                      _searchQuery,
                    ) ||
                incident.location.toLowerCase().contains(
                      _searchQuery,
                    );

            return matchesStatus && matchesSearch;
          }).toList();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Campus Incident Reports',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Signed in as ${auth.user?.email ?? ''}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Review and manage reports submitted by students.',
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.35,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _buildStatCard(
                          'Total Reports',
                          incidents.length,
                          Icons.folder_outlined,
                          Colors.indigo,
                        ),
                        _buildStatCard(
                          'Pending',
                          pendingCount,
                          Icons.pending_actions,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Under Review',
                          reviewCount,
                          Icons.manage_search,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Resolved',
                          resolvedCount,
                          Icons.check_circle_outline,
                          Colors.green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'All Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search reports',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery =
                              value.trim().toLowerCase();
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Filter by status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

                    const SizedBox(height: 16),

                    if (incidents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text('No incident reports yet.'),
                        ),
                      )
                    else if (filteredIncidents.isEmpty)
                      SizedBox(
                        height: 200,
                        child: _buildEmptyState(),
                      )
                    else
                      ...filteredIncidents.map(_buildReportCard),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
