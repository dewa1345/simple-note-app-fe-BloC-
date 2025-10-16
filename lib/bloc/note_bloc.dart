import 'dart:async';
import '../event/note_event.dart';
import '../state/note_state.dart';
import '../repository/note_repository.dart';

class NoteBloc {
  final StreamController<NoteState> _stateController = StreamController<NoteState>.broadcast();
  
  NoteState _state = NotesInitial();
  NoteState get state => _state;
  Stream<NoteState> get stateStream => _stateController.stream;

  final NoteRepository repository;

  NoteBloc(this.repository);

  void dispatch(NoteEvent event) {
    if (event is LoadNotes) {
      _state = NotesLoaded(repository.getNotes());
    } else if (event is AddNote) {
      repository.addNote(event.title, event.body);
      _state = NotesLoaded(repository.getNotes());
    } else if (event is UpdateNote) {
      repository.updateNote(event.id, event.title, event.body);
      _state = NotesLoaded(repository.getNotes());
    } else if (event is DeleteNotes) {
      repository.deleteNotes(event.ids);
      _state = NotesLoaded(repository.getNotes());
    }
    
    // Emit new state to stream
    _stateController.add(_state);
  }

  void dispose() {
    _stateController.close();
  }
}
