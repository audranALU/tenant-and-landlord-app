import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceRequestModel {
  final Timestamp createdAt;
  final String id;
  final String tenantId;
  final String category;
  final String urgency;
  final String location;
  final String description;
  final String imageUrl;
  final String status;

  MaintenanceRequestModel({
    required this.id,
    required this.tenantId,
    required this.category,
    required this.urgency,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "tenantId": tenantId,
      "category": category,
      "urgency": urgency,
      "location": location,
      "description": description,
      "imageUrl": imageUrl,
      "status": status,
      "createdAt": createdAt,
    };
  }

  factory MaintenanceRequestModel.fromMap(
      String id,
      Map<String,dynamic> map) {

    return MaintenanceRequestModel(
      id: id,
      tenantId: map["tenantId"],
      category: map["category"],
      urgency: map["urgency"],
      location: map["location"],
      description: map["description"],
      imageUrl: map["imageUrl"],
      status: map["status"],
      createdAt: map["createdAt"],
    );
  }
}