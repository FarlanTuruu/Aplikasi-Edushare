// /lib/app/models/note_model.dart
import 'package:intl/intl.dart';

class NoteModel {
  final String id;
  final String title;
  final String mataKuliah;
  final DateTime date;
  final String description;
  final String? fileName;

  NoteModel({
    required this.id,
    required this.title,
    required this.mataKuliah,
    required this.date,
    required this.description,
    this.fileName,
  });

  // helper untuk menampilkan
  String get day => DateFormat('dd').format(date);
  String get month => DateFormat('MMM').format(date);
  String get fullDate => DateFormat('dd/MM/yyyy').format(date);

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
      mataKuliah: map['mataKuliah']?.toString() ?? '',
      date: parsed,
      description: map['description']?.toString() ?? '',
      fileName: map['fileName'] != null ? map['fileName']?.toString() : null,
    );
  }
}
