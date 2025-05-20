import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../core/providers/offline_data_provider.dart';
import '../../core/services/connectivity_service.dart';
import '../models/note_model.dart';
import '../repositories/note_repository.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return getIt<NoteRepository>();
});

final noteProvider = createOfflineDataProvider<NoteModel>(
  repository: getIt<NoteRepository>(),
  connectivityService: getIt<ConnectivityService>(),
  fetchItems: () => getIt<NoteRepository>().getNotes(),
);
