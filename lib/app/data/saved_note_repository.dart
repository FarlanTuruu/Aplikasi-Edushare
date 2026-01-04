import 'api_client.dart';

class SavedNoteRepository {
  final ApiClient api;
  SavedNoteRepository(this.api);

  Future<List<dynamic>> listSaved() async {
    return await api.getList('saved-notes');
  }

  // Matches routes: POST /notes/{id}/save and DELETE /notes/{id}/save
  Future<void> save(String noteId) async {
    await api.postJson('notes/$noteId/save', {});
  }

  Future<void> unsave(String noteId) async {
    await api.delete('notes/$noteId/save');
  }
}
