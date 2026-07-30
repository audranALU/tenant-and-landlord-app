import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tenant_and_landlord_app/models/maintenance_request_model.dart';

/// Unit tests for the landlord feature
/// These tests cover model mapping and filter logic
/// without requiring Firebase emulator connections.

void main() {
  group('MaintenanceRequestModel', () {
    test('fromMap creates model correctly', () {
      final map = {
        "tenantId": "tenant123",
        "category": "plumbing",
        "urgency": "high",
        "location": "Kitchen",
        "description": "Sink is leaking",
        "imageUrl": "https://example.com/image.jpg",
        "status": "open",
        "createdAt": Timestamp.now(),
      };

      final model = MaintenanceRequestModel.fromMap("doc123", map);

      expect(model.id, "doc123");
      expect(model.tenantId, "tenant123");
      expect(model.category, "plumbing");
      expect(model.urgency, "high");
      expect(model.location, "Kitchen");
      expect(model.description, "Sink is leaking");
      expect(model.status, "open");
    });

    test('toMap produces correct map without id', () {
      final model = MaintenanceRequestModel(
        id: "doc123",
        tenantId: "tenant456",
        category: "electrical",
        urgency: "medium",
        location: "Bedroom",
        description: "Outlet not working",
        imageUrl: "",
        status: "assigned",
        createdAt: Timestamp.now(),
      );

      final map = model.toMap();

      expect(map.containsKey("id"), false);
      expect(map["tenantId"], "tenant456");
      expect(map["category"], "electrical");
      expect(map["urgency"], "medium");
      expect(map["status"], "assigned");
    });

    test('toMap and fromMap are consistent', () {
      final timestamp = Timestamp.now();
      final original = MaintenanceRequestModel(
        id: "test1",
        tenantId: "t1",
        category: "structural",
        urgency: "low",
        location: "Living Room",
        description: "Crack in wall",
        imageUrl: "https://example.com/crack.jpg",
        status: "in_progress",
        createdAt: timestamp,
      );

      final map = original.toMap();
      final rebuilt = MaintenanceRequestModel.fromMap("test1", map);

      expect(rebuilt.id, original.id);
      expect(rebuilt.tenantId, original.tenantId);
      expect(rebuilt.category, original.category);
      expect(rebuilt.urgency, original.urgency);
      expect(rebuilt.location, original.location);
      expect(rebuilt.description, original.description);
      expect(rebuilt.imageUrl, original.imageUrl);
      expect(rebuilt.status, original.status);
    });
  });

  group('Filter logic', () {
    final testRequests = [
      MaintenanceRequestModel(
        id: "1",
        tenantId: "t1",
        category: "plumbing",
        urgency: "high",
        location: "Kitchen",
        description: "Leak",
        imageUrl: "",
        status: "open",
        createdAt: Timestamp.now(),
      ),
      MaintenanceRequestModel(
        id: "2",
        tenantId: "t1",
        category: "electrical",
        urgency: "medium",
        location: "Bedroom",
        description: "Outlet broken",
        imageUrl: "",
        status: "assigned",
        createdAt: Timestamp.now(),
      ),
      MaintenanceRequestModel(
        id: "3",
        tenantId: "t2",
        category: "structural",
        urgency: "low",
        location: "Hall",
        description: "Crack",
        imageUrl: "",
        status: "in_progress",
        createdAt: Timestamp.now(),
      ),
      MaintenanceRequestModel(
        id: "4",
        tenantId: "t2",
        category: "pest",
        urgency: "medium",
        location: "Bathroom",
        description: "Ants",
        imageUrl: "",
        status: "resolved",
        createdAt: Timestamp.now(),
      ),
    ];

    test('filter by status "open" returns only open requests', () {
      final filtered =
          testRequests.where((r) => r.status == "open").toList();
      expect(filtered.length, 1);
      expect(filtered.first.id, "1");
    });

    test('filter by status "assigned" returns only assigned requests', () {
      final filtered =
          testRequests.where((r) => r.status == "assigned").toList();
      expect(filtered.length, 1);
      expect(filtered.first.id, "2");
    });

    test('filter by status "in_progress" returns correct requests', () {
      final filtered =
          testRequests.where((r) => r.status == "in_progress").toList();
      expect(filtered.length, 1);
      expect(filtered.first.id, "3");
    });

    test('filter by status "resolved" returns correct requests', () {
      final filtered =
          testRequests.where((r) => r.status == "resolved").toList();
      expect(filtered.length, 1);
      expect(filtered.first.id, "4");
    });

    test('"all" filter returns every request', () {
      // "all" means no filtering
      final filtered = testRequests;
      expect(filtered.length, 4);
    });

    test('count calculation is correct', () {
      int open = 0, assigned = 0, inProgress = 0, resolved = 0;
      for (var r in testRequests) {
        switch (r.status) {
          case "open":
            open++;
            break;
          case "assigned":
            assigned++;
            break;
          case "in_progress":
            inProgress++;
            break;
          case "resolved":
            resolved++;
            break;
        }
      }
      expect(open, 1);
      expect(assigned, 1);
      expect(inProgress, 1);
      expect(resolved, 1);
      expect(testRequests.length, 4);
    });
  });
}
