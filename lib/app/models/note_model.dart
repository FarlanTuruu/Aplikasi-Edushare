// /lib/app/models/note_model.dart
import 'package:intl/intl.dart';

class NoteModel {
  final String id;
  final String title;
  final String mataKuliah;
  final DateTime date;
  final String description;
  final String? fileName;
  final String? status; // e.g., list, draft, scheduled, archived

  NoteModel({
    required this.id,
    required this.title,
    required this.mataKuliah,
    required this.date,
    required this.description,
    this.fileName,
    this.status,
  });

  // helper untuk menampilkan
  String get day => DateFormat('dd').format(date);
  String get month => DateFormat('MMM').format(date);
  String get fullDate => DateFormat('dd/MM/yyyy').format(date);

  NoteModel copyWith({
    String? id,
    String? title,
    String? mataKuliah,
    DateTime? date,
    String? description,
    String? fileName,
    String? status,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      mataKuliah: mataKuliah ?? this.mataKuliah,
      date: date ?? this.date,
      description: description ?? this.description,
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
    );
  }

  // Convert NoteModel -> Map (mis. kalau mau pass via arguments)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'mataKuliah': mataKuliah,
      // simpan sebagai ISO string agar aman lewat arguments/serializable
      'date': date.toIso8601String(),
      'description': description,
      'fileName': fileName,
      'status': status,
    };
  }

  // Create dari Map
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    DateTime parsed;
    if (map['date'] is DateTime) {
      parsed = map['date'] as DateTime;
    } else if (map['date'] is String) {
      parsed = DateTime.tryParse(map['date'] as String) ?? DateTime.now();
    } else {
      parsed = DateTime.now();
    }

    return NoteModel(
      id:
          map['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? '',
      // accept both camelCase and snake_case input
      mataKuliah: (map['mataKuliah'] ?? map['mata_kuliah'])?.toString() ?? '',
      date: parsed,
      description: map['description']?.toString() ?? '',
      fileName: (map['fileName'] ?? map['file_name']) != null
          ? (map['fileName'] ?? map['file_name']).toString()
          : null,
      status: map['status']?.toString(),
    );
  }

  // Map to API (snake_case keys)
  Map<String, dynamic> toApiMap({String? overrideStatus}) {
    return {
      'title': title,
      'mata_kuliah': mataKuliah,
      'description': description,
      // Send date as Y-m-d to satisfy Laravel date_format:Y-m-d
      'date': DateFormat('dd-MM-yyyy').format(date),
      if ((overrideStatus ?? status) != null)
        'status': (overrideStatus ?? status),
      if (fileName != null) 'file_name': fileName,
    };
  }

  // Create from API (snake_case keys)
  factory NoteModel.fromApi(Map<String, dynamic> map) {
    final rawDate = map['date'];
    DateTime parsed;
    if (rawDate is String) {
      DateTime? p = DateTime.tryParse(rawDate);
      p ??= _tryFormat('yyyy-MM-dd', rawDate);
      p ??= _tryFormat('dd-MM-yyyy', rawDate);
      p ??= _tryFormat('dd/MM/yyyy', rawDate);
      parsed = p ?? DateTime.now();
    } else if (rawDate is DateTime) {
      parsed = rawDate;
    } else {
      parsed = DateTime.now();
    }

    return NoteModel(
      id:
          map['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? '',
      mataKuliah: (map['mata_kuliah'] ?? map['mataKuliah'])?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      fileName: map['file_name']?.toString(),
      status: map['status']?.toString(),
      date: parsed,
    );
  }

  static DateTime? _tryFormat(String pattern, String value) {
    try {
      return DateFormat(pattern).parseStrict(value);
    } catch (_) {
      return null;
    }
  }
}
