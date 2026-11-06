
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';

class IncidentService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Submit a new incident.
  Future<void> createIncident(Incident incident) async {
    await _firestore.collection('incidents').add(
      incident.toMap(),
    );
  }

  // Retrieve incidents belonging to one student.
  Stream<List<Incident>> getUserIncidents(String userId) {
    return _firestore
        .collection('incidents')
        .where('reporterId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Incident.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Retrieve all campus incidents (staff only).
  Stream<List<Incident>> getAllIncidents() {
    return _firestore
        .collection('incidents')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Incident.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Retrieve one incident.
  Future<Incident?> getIncident(String id) async {
    final doc = await _firestore
        .collection('incidents')
        .doc(id)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return Incident.fromMap(doc.id, doc.data()!);
  }
}
