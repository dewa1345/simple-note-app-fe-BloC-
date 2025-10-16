abstract class NoteState {}

class NotesInitial extends NoteState {}
class NotesLoading extends NoteState {}
class NotesLoaded extends NoteState {
  final List<Map<String, dynamic>> notes;
  NotesLoaded(this.notes);
}
class NotesError extends NoteState {
  final String message;
  NotesError(this.message);
}
