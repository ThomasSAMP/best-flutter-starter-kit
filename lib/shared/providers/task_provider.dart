import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../core/providers/offline_data_provider.dart';
import '../../core/services/connectivity_service.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return getIt<TaskRepository>();
});

final taskProvider = createOfflineDataProvider<TaskModel>(
  repository: getIt<TaskRepository>(),
  connectivityService: getIt<ConnectivityService>(),
  fetchItems: () => getIt<TaskRepository>().getTasks(),
);

// Provider pour les tâches incomplètes
final incompletedTasksProvider = Provider<List<TaskModel>>((ref) {
  final state = ref.watch(taskProvider);
  return state.items.where((task) => !task.isCompleted).toList();
});

// Provider pour les tâches terminées
final completedTasksProvider = Provider<List<TaskModel>>((ref) {
  final state = ref.watch(taskProvider);
  return state.items.where((task) => task.isCompleted).toList();
});
