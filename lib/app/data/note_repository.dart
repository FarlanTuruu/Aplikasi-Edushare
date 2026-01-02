import '../models/note_model.dart';
import 'api_client.dart';

class NoteRepository {
  final ApiClient api;
  NoteRepository(this.api);

  // Adjust paths to match Laravel routes (e.g., /notes)
  Future<List<NoteModel>> fetchNotes() async {
    // Authenticated, owner-specific list
    final data = await api.getList('notes');
    return data
        .map(
          (e) => NoteModel.fromApi(
            e is Map<String, dynamic> ? e : <String, dynamic>{},
          ),
        )
        .toList();
  }

  // Explicit public/published feed for all users
  Future<List<NoteModel>> fetchNotesPublic() async {
    final data = await api.getList('public/notes');
    return data
        .map(
          (e) => NoteModel.fromApi(
            e is Map<String, dynamic> ? e : <String, dynamic>{},
          ),
        )
        .toList();
  }

  Future<List<NoteModel>> fetchDrafts() async {
    List<dynamic> data;
    try {
      data = await api.getList('notes/drafts');
    } catch (_) {
      data = const [];
    }
    return data
        .map((e) => NoteModel.fromApi(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NoteModel>> fetchScheduled() async {
    List<dynamic> data;
    try {
      data = await api.getList('notes/scheduled');
    } catch (_) {
      data = const [];
    }
    return data
        .map((e) => NoteModel.fromApi(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NoteModel>> fetchArchived() async {
    List<dynamic> data;
    try {
      data = await api.getList('notes/archived');
    } catch (_) {
      data = const [];
    }
    return data
        .map((e) => NoteModel.fromApi(e as Map<String, dynamic>))
        .toList();
  }

  Future<NoteModel> createNote(NoteModel note) async {
    final payload = note.toApiMap();
    // Debug log to verify payload shape, especially date format
    // Remove if too verbose in production
    // ignore: avoid_print
    print('[NotesRepository] POST /notes payload => ' + payload.toString());
    final data = await api.postJson('notes', payload);
    // API might wrap the created resource in {data: {...}}
    final map = (data['data'] is Map<String, dynamic>)
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return NoteModel.fromApi(map);
  }

  Future<NoteModel> createNoteWithFile(NoteModel note, String filePath) async {
    final payload = note.toApiMap();
    // Remove file_name key; server will generate it from uploaded file
    payload.remove('file_name');

    // Convert dynamic map to Map<String, String>
    final fields = <String, String>{};
    payload.forEach((k, v) {
      if (v != null) fields[k] = v.toString();
    });

    // ignore: avoid_print
    print(
      '[NotesRepository] POST /notes multipart fields => ' + fields.toString(),
    );

    final data = await api.postWithFile('notes', 'file', filePath, fields);
    final map = (data['data'] is Map<String, dynamic>)
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return NoteModel.fromApi(map);
  }

  Future<NoteModel> updateNote(NoteModel note) async {
    final payload = note.toApiMap();
    final data = await api.putJson('notes/${note.id}', payload);
    final map = (data['data'] is Map<String, dynamic>)
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return NoteModel.fromApi(map);
  }

  Future<void> deleteNote(String id) async {
    await api.delete('notes/$id');
  }

  Future<void> publish(String id) async {
    await api.postJson('notes/$id/publish', {});
  }

  Future<void> archive(String id) async {
    await api.postJson('notes/$id/archive', {});
  }

  Future<void> unarchive(String id) async {
    await api.postJson('notes/$id/unarchive', {});
  }

  Future<void> save(String id) async {
    await api.postJson('notes/$id/save', {});
  }

  Future<void> unsave(String id) async {
    await api.delete('notes/$id/save');
  }
}
