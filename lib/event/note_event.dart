abstract class NoteEvent {}

class LoadNotes extends NoteEvent {}
class AddNote extends NoteEvent {
  final String title;
  final String body;
  AddNote(this.title, this.body);
}
class UpdateNote extends NoteEvent {
  final int id;
  final String title;
  final String body;
  UpdateNote(this.id, this.title, this.body);
}
class DeleteNotes extends NoteEvent {
  final List<int> ids;
  DeleteNotes(this.ids);
}
