import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String description;
  final String category;
  final String location;
  final String reporterId;
  final String status;
  final String? photoUrl;
  final Timestamp? createdAt;

  Incident({
    required this.id,
    required this.description,
    required this.category,
    required this.location,
    required this.reporterId,
    this.status = 'pending',
    this.photoUrl,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'category': category,
      'location': location,
      'reporterId': reporterId,
      'status': status,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Incident.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Incident(
      id: id,
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      reporterId: map['reporterId'] ?? '',
      status: map['status'] ?? 'pending',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}