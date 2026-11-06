import 'package:flutter_test/flutter_test.dart';
import 'package:campus_care/models/incident.dart';

void main() {
  test('Incident uses pending as its default status', () {
    final incident = Incident(
      id: 'test-1',
      description: 'Broken classroom chair',
      category: 'Maintenance',
      location: 'Block A',
      reporterId: 'student-1',
    );

    expect(incident.status, 'pending');
    expect(incident.description, 'Broken classroom chair');
    expect(incident.location, 'Block A');
  });
}