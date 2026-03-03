import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../shared/widgets/atoms/app_status_badge.dart';
import '../../domain/entities/task.dart';

/// Modèle de données Firestore pour une tâche.
///
/// Gère la sérialisation / désérialisation depuis Firestore.
/// Conversion vers l'entité domaine via [toEntity].
class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.assignedTo,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;
  final String assignedTo;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'] as String,
      assignedTo: data['assignedTo'] as String,
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, Object> toJson() => {
        'title': title,
        'description': description,
        'dueDate': Timestamp.fromDate(dueDate),
        'status': status,
        'assignedTo': assignedTo,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  Task toEntity() => Task(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate,
        status: TaskStatus.fromString(status),
        assignedTo: assignedTo,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
