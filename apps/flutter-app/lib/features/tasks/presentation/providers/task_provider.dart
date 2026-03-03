import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/services/user_service.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/widgets/atoms/app_status_badge.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/entities/task.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

/// Provider du repository de tâches.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(firestore: ref.watch(firestoreProvider));
});

// ─── Fetch : liste des tâches de l'élève connecté ────────────────────────────

/// Fetch one-shot des tâches assignées à l'élève connecté.
final tasksByEleveProvider = FutureProvider<List<Task>>((ref) async {
  final user = await ref.watch(currentUserModelProvider.future);
  if (user == null) return [];
  return ref.read(taskRepositoryProvider).getTasksByEleve(user.uid);
});

// ─── Fetch : liste des tâches créées par le bénévole connecté ────────────────

/// Fetch one-shot des tâches créées par le bénévole connecté.
final tasksByVolunteerProvider = FutureProvider<List<Task>>((ref) async {
  final user = await ref.watch(currentUserModelProvider.future);
  if (user == null) return [];
  return ref.read(taskRepositoryProvider).getTasksByVolunteer(user.uid);
});

// ─── Fetch : élèves du bénévole connecté ─────────────────────────────────────

/// Liste des élèves assignés au bénévole connecté.
final studentsForVolunteerProvider =
    FutureProvider<List<UserModel>>((ref) async {
  final user = await ref.watch(currentUserModelProvider.future);
  if (user == null) return [];
  final userService = UserService(ref.watch(firestoreProvider));
  return userService.getStudentsForVolunteer(user.uid);
});

// ─── Fetch : détail d'une tâche ───────────────────────────────────────────────

/// Fetch one-shot du détail d'une tâche par son identifiant.
final taskDetailProvider =
    FutureProvider.family<Task?, String>((ref, taskId) async {
  return ref.read(taskRepositoryProvider).getTaskById(taskId);
});

// ─── Filtre statut ────────────────────────────────────────────────────────────

/// Filtre actif sur la liste des tâches.
/// `null` = tous les statuts.
final taskStatusFilterProvider = StateProvider<TaskStatus?>((ref) => null);

// ─── Mise à jour du statut ────────────────────────────────────────────────────

/// Notifier pour la mise à jour du statut d'une tâche.
class TaskStatusNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Met à jour le statut d'une tâche et invalide les providers dépendants.
  Future<void> updateStatus(String taskId, TaskStatus newStatus) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(taskRepositoryProvider)
          .updateTaskStatus(taskId, newStatus.value);
      ref.invalidate(tasksByEleveProvider);
      ref.invalidate(taskDetailProvider(taskId));
    });
  }
}

final taskStatusNotifierProvider =
    AsyncNotifierProvider<TaskStatusNotifier, void>(TaskStatusNotifier.new);

// ─── Création de tâche (bénévole) ─────────────────────────────────────────────

/// Notifier pour la création d'une tâche par un bénévole.
class CreateTaskNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required String assignedTo,
    required String createdBy,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(taskRepositoryProvider).createTask(
            title: title,
            description: description,
            dueDate: dueDate,
            assignedTo: assignedTo,
            createdBy: createdBy,
          );
      ref.invalidate(tasksByVolunteerProvider);
    });
  }
}

final createTaskNotifierProvider =
    AsyncNotifierProvider<CreateTaskNotifier, void>(CreateTaskNotifier.new);
