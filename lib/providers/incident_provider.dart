
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _incidentService = IncidentService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> submitIncident({
    required String description,
    required String category,
    required String location,
    String? photoUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || !user.emailVerified) {
      _errorMessage = 'Please log in with a verified account.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final incident = Incident(
        id: '',
        description: description.trim(),
        category: category,
        location: location.trim(),
        reporterId: user.uid,
        photoUrl: photoUrl,
      );

      await _incidentService.createIncident(incident);
      return true;
    } catch (e) {
      _errorMessage = 'Could not submit incident. Please try again.';
      debugPrint('Incident submission error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    // Update an incident's status.
  }
  // Update an incident's status.
    Future<bool> updateIncidentStatus({
      required String incidentId,
      required String status,
    }) async {
      try {
        await _incidentService.updateIncidentStatus(
          incidentId: incidentId,
          status: status,
        );

        return true;
      } catch (e) {
        debugPrint('Status update error: $e');
        _errorMessage = 'Could not update incident status.';
        notifyListeners();
        return false;
      }
    }

  Stream<List<Incident>> getUserIncidents(String userId) {
    return _incidentService.getUserIncidents(userId);
  }
  Stream<List<Incident>> getAllIncidents() {
  return _incidentService.getAllIncidents();
}
}
