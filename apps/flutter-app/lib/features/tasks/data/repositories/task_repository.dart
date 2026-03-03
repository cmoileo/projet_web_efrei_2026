import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';

/// Repository Firestore pour les tâches.
///
/// Toutes les opérations Firestore liées aux tâches sont centralisées ici.
/// Utilise des fetch one-shot (`get()`) conformément aux contraintes techniques.
class TaskRepository {
  const TaskRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Récupère toutes les tâches assignées à un élève (one-shot).
  Future<List<Task>> getTasksByEleve(String uid) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.tasks)
        .where('assignedTo', isEqualTo: uid)
        .get();

    final tasks = snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc).toEntity())
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return tasks;
  }

  /// Récupère le détail d'une tâche par son identifiant.
  Future<Task?> getTaskById(String taskId) async {
    final doc = await _firestore
        .collection(FirestoreCollections.tasks)
        .doc(taskId)
        .get();

    if (!doc.exists) return null;
    return TaskModel.fromFirestore(doc).toEntity();
  }

  /// Met à jour uniquement le statut et `updatedAt` d'une tâche.
  ///
  /// Conforme aux règles de sécurité Firestore :
  /// un élève ne peut modifier que `status` et `updatedAt`.
  Future<void> updateTaskStatus(String taskId, String status) async {
    await _firestore.collection(FirestoreCollections.tasks).doc(taskId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Récupère toutes les tâches créées par un bénévole (one-shot).
  Future<List<Task>> getTasksByVolunteer(String uid) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.tasks)
        .where('createdBy', isEqualTo: uid)
        .get();

    final tasks = snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc).toEntity())
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return tasks;
  }

  /// Crée une nouvelle tâche.
  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required String assignedTo,
    required String createdBy,
  }) async {
    await _firestore.collection(FirestoreCollections.tasks).add({
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': 'todo',
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
