import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/models/note_model.dart';
import '../../../../shared/repositories/note_repository.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/connectivity_indicator.dart';

class OfflineTestScreen extends ConsumerStatefulWidget {
  const OfflineTestScreen({super.key});

  @override
  ConsumerState<OfflineTestScreen> createState() => _OfflineTestScreenState();
}

class _OfflineTestScreenState extends ConsumerState<OfflineTestScreen> {
  final _noteRepository = getIt<NoteRepository>();
  final _connectivityService = getIt<ConnectivityService>();
  final _navigationService = getIt<NavigationService>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final notes = await _noteRepository.getNotes();
      setState(() {
        _notes = notes;
        _statusMessage = 'Notes chargées avec succès (${notes.length})';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erreur lors du chargement des notes: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Le titre et le contenu sont requis';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await _noteRepository.createNote(_titleController.text, _contentController.text);

      // Réinitialiser les champs
      _titleController.clear();
      _contentController.clear();

      // Recharger les notes
      await _loadNotes();

      setState(() {
        _statusMessage =
            'Note créée avec succès${_connectivityService.currentStatus == ConnectionStatus.offline ? ' (en mode hors ligne)' : ''}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erreur lors de la création de la note: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNote(String noteId) async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await _noteRepository.deleteNote(noteId);

      // Recharger les notes
      await _loadNotes();

      setState(() {
        _statusMessage =
            'Note supprimée avec succès${_connectivityService.currentStatus == ConnectionStatus.offline ? ' (en mode hors ligne)' : ''}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erreur lors de la suppression de la note: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncWithServer() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await _noteRepository.syncWithServer();

      // Recharger les notes
      await _loadNotes();

      setState(() {
        _statusMessage = 'Synchronisation avec le serveur réussie';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erreur lors de la synchronisation: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkConnectivity() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final status = await _connectivityService.checkConnectivity();

      setState(() {
        _statusMessage =
            'Statut de connexion: ${status == ConnectionStatus.online ? 'En ligne' : 'Hors ligne'}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erreur lors de la vérification de la connectivité: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

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
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: _loadNotes,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              onPressed: _isLoading ? null : _createNote,
                              isLoading: _isLoading,
                            ),

                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Actions
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    text: 'Synchroniser',
                                    onPressed: _isLoading ? null : _syncWithServer,
                                    isLoading: _isLoading,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: AppButton(
                                    text: 'Vérifier connexion',
                                    onPressed: _isLoading ? null : _checkConnectivity,
                                    isLoading: _isLoading,
                                    type: AppButtonType.outline,
                                  ),
                                ),
                              ],
                            ),

                            if (_statusMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      _statusMessage!.contains('Erreur')
                                          ? Theme.of(context).colorScheme.errorContainer
                                          : Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(_statusMessage!),
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

                            if (_notes.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Aucune note'),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _notes.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final note = _notes[index];
                                  return ListTile(
                                    title: Text(note.title),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          note.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              note.isSynced ? Icons.cloud_done : Icons.cloud_off,
                                              size: 16,
                                              color: note.isSynced ? Colors.green : Colors.orange,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              note.isSynced ? 'Synchronisé' : 'Non synchronisé',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: note.isSynced ? Colors.green : Colors.orange,
                                              ),
                                            ),
                                          ],
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
