// (removed misplaced code/comments before imports)
import 'dart:async';
import 'package:flutter/material.dart';
import 'bloc/note_bloc.dart';
import 'event/note_event.dart' as noteEvent;
import 'state/note_state.dart';
import 'repository/note_repository.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Taking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NoteList(),
    );
  }
}

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  late NoteBloc bloc;
  List<Map<String, dynamic>> notes = [];
  List<Map<String, dynamic>> selectedNotes = [];
  bool isSelectionMode = false;
  late StreamSubscription<NoteState> _stateSubscription;

  @override
  void initState() {
    super.initState();
    bloc = NoteBloc(NoteRepository()); // Now uses singleton
    
    // Listen to BLoC state stream
    _stateSubscription = bloc.stateStream.listen((state) {
      if (state is NotesLoaded) {
        setState(() {
          notes = state.notes;
        });
      }
    });
    
    // Load initial notes
    bloc.dispatch(noteEvent.LoadNotes());
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    bloc.dispose();
    super.dispose();
  }

  void fetchNotes() {
    bloc.dispatch(noteEvent.LoadNotes());
  }

  void deleteSelectedNotes() {
    final ids = selectedNotes.map((note) => note['ID'] as int).toList();
  bloc.dispatch(noteEvent.DeleteNotes(ids));
    fetchNotes();
    setState(() {
      selectedNotes.clear();
      isSelectionMode = false;
    });
  }

  @override
  // ...existing code...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note List'),
        actions: [
          if (!isSelectionMode)
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  isSelectionMode = true;
                  selectedNotes = List.from(notes);
                });
              },
            ),
          if (isSelectionMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: deleteSelectedNotes,
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notes[index]['title']),
            subtitle: Text(notes[index]['body']),
            onTap: () {
              if (isSelectionMode) {
                setState(() {
                  if (selectedNotes.contains(notes[index])) {
                    selectedNotes.remove(notes[index]);
                  } else {
                    selectedNotes.add(notes[index]);
                  }
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetail(
                      id: notes[index]['ID'],
                      note: notes[index],
                      bloc: bloc,
                    ),
                  ),
                );
              }
            },
            leading: isSelectionMode
                ? Checkbox(
                    value: selectedNotes.contains(notes[index]),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          selectedNotes.add(notes[index]);
                        } else {
                          selectedNotes.remove(notes[index]);
                        }
                      });
                    },
                  )
                : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNote(
                bloc: bloc, // Pass the BLoC instance
              ),
            ),
          ).then((value) {
            if (value == true) fetchNotes();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class NoteDetail extends StatelessWidget {
  final dynamic note;
  final int id;
  final NoteBloc bloc;
  NoteDetail({required this.note, required this.id, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateNoteScreen(
                    note: note,
                    id: note['ID'],
                    bloc: bloc, // Pass BLoC instance
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note['title'],
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(note['body']),
          ],
        ),
      ),
    );
  }
}

class UpdateNoteScreen extends StatefulWidget {
  final dynamic note;
  final int id;
  final NoteBloc bloc;
  UpdateNoteScreen({required this.note, required this.id, required this.bloc});

  @override
  _UpdateNoteScreenState createState() => _UpdateNoteScreenState();
}

class _UpdateNoteScreenState extends State<UpdateNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note['title']);
    _contentController = TextEditingController(text: widget.note['body']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: null,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Use BLoC properly - dispatch UpdateNote event
                widget.bloc.dispatch(noteEvent.UpdateNote(widget.id, _titleController.text, _contentController.text));
                // show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Note updated')),
                );
                Navigator.pop(context, true);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddNote extends StatefulWidget {
  final NoteBloc bloc;
  AddNote({required this.bloc});

  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: null,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                print('=== ADD BUTTON PRESSED ===');
                print('Title: ${_titleController.text}');
                print('Content: ${_contentController.text}');
                
                if (_titleController.text.isEmpty) {
                  print('WARNING: Title is empty!');
                  return;
                }
                
                // Use BLoC properly - dispatch AddNote event
                widget.bloc.dispatch(noteEvent.AddNote(_titleController.text, _contentController.text));
                
                // show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Note added')),
                );
                Navigator.pop(context, true);
              },
              child: Text('Add Note'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
