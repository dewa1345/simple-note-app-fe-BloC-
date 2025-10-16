class NoteRepository {
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal();

  final List<Map<String, dynamic>> _notes = [];
  int _idCounter = 1;

  List<Map<String, dynamic>> getNotes() {
    return List<Map<String, dynamic>>.from(_notes);
  }

  void addNote(String title, String body) {
    _notes.add({
      'ID': _idCounter++,
      'title': title,
      'body': body,
    });
    print('Note added: $_notes');
  }

  void updateNote(int id, String title, String body) {
    final index = _notes.indexWhere((note) => note['ID'] == id);
    if (index != -1) {
      _notes[index]['title'] = title;
      _notes[index]['body'] = body;
      print('Note updated: $_notes');
    }
  }

  void deleteNotes(List<int> ids) {
    _notes.removeWhere((note) => ids.contains(note['ID']));
    print('Notes after delete: $_notes');
  }
}
