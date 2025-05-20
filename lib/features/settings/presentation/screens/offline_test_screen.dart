import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/models/note_model.dart';
import '../../../../shared/providers/note_provider.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/connectivity_indicator.dart';
import '../../../../shared/widgets/sync_manager.dart';
import '../../../../shared/widgets/sync_status_badge.dart';

class OfflineTestScreen extends ConsumerStatefulWidget {
  const OfflineTestScreen({super.key});

  @override
  ConsumerState<OfflineTestScreen> createState() => _OfflineTestScreenState();
}

class _OfflineTestScreenState extends ConsumerState<OfflineTestScreen> {
  final _navigationService = getIt<NavigationService>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isCreating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Le titre et le contenu sont requis';
      });
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(noteRepositoryProvider);
      await repository.createNote(_titleController.text, _contentController.text);

      // Réinitialiser les champs
      _titleController.clear();
      _contentController.clear();

      // Recharger les notes
      ref.read(noteProvider.notifier).loadItems();

      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la création de la note: $e';
      });
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      final repository = ref.read(noteRepositoryProvider);
      await repository.deleteNote(noteId);

      // Recharger les notes
      ref.read(noteProvider.notifier).loadItems();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la suppression de la note: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    final notesState = ref.watch(noteProvider);
    final connectivityService = getIt<ConnectivityService>();

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Off-Line Test',
        showBackButton: canPop,
        leading:
            !canPop
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _navigationService.navigateTo(context, '/settings'),
                )
                : null,
      ),
      body: Column(
        children: [
          // Indicateur de connectivité
          const ConnectivityIndicator(),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(noteProvider.notifier).loadItems(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gestionnaire de synchronisation
                    SyncManager<NoteModel>(provider: noteProvider, entityName: 'Notes'),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Formulaire de création de note
                    const Text(
                      'Créer une note',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _titleController,
                      label: 'Titre',
                      hint: 'Entrez le titre de la note',
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _contentController,
                      label: 'Contenu',
                      hint: 'Entrez le contenu de la note',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Créer une note',
                      onPressed: _isCreating ? null : _createNote,
                      isLoading: _isCreating,
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_errorMessage!),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Liste des notes
                    const Text(
                      'Notes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    if (notesState.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (notesState.items.isEmpty)
                      const Center(
                        child: Padding(padding: EdgeInsets.all(16.0), child: Text('Aucune note')),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notesState.items.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final note = notesState.items[index];
                          return ListTile(
                            title: Text(note.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                SyncStatusBadge(
                                  isSynced: note.isSynced,
                                  connectionStatus: notesState.connectionStatus,
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteNote(note.id),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Instructions
                    const Text(
                      'Instructions de test',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Créez des notes en mode connecté et vérifiez qu\'elles sont synchronisées\n'
                      '2. Activez le mode avion sur votre appareil\n'
                      '3. Créez des notes en mode hors ligne\n'
                      '4. Vérifiez que les notes sont marquées comme "Non synchronisé"\n'
                      '5. Désactivez le mode avion\n'
                      '6. Appuyez sur "Synchroniser" pour envoyer les notes au serveur\n'
                      '7. Vérifiez que toutes les notes sont maintenant synchronisées',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
