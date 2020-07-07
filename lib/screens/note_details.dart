import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttersqlite/models/note.dart';
import 'package:fluttersqlite/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String AppBartitle;
  final Note note;

  NoteDetail(this.note, this.AppBartitle);

  @override
  State<StatefulWidget> createState() =>
      _NoteDetailState(this.note, this.AppBartitle);
}

class _NoteDetailState extends State<NoteDetail> {
  String appBartitle;
  Note note;

  DatabaseHelper helper = DatabaseHelper();

  static var _properties = ["High", "Low"];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  _NoteDetailState(this.note, this.appBartitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.title;
    descriptionController.text = note.desc;

    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBartitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: DropdownButton(
                  items: _properties.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priotiry),
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      debugPrint("User Selected $valueSelectedByUser");
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint("Something changed in Title TF");
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint("Something changed in Title TF");
                    updateDesc();
                  },
                  decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Wrap(
                  children: <Widget>[
                    RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        "Save",
                        textScaleFactor: 1.5,
                      ),
                      onPressed: () {
                        debugPrint("Save button clicked");
                        _save();
                      },
                    )
                  ],
                ),
              ),
              Container(width: 5.0),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        "Delete",
                        textScaleFactor: 1.5,
                      ),
                      onPressed: () {
                        debugPrint("Delete button clicked");
                        _delete();
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  //Convert the String priority in the form of Integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priotiry = 1;
        break;
      case "Low":
        note.priotiry = 2;
        break;
    }
  }

  //Convert int priority to String priority and display it to user in dropdown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _properties[0];
        break;
      case 2:
        priority = _properties[1];
        break;
    }
    return priority;
  }

  //Update tile of Note Object
  void updateTitle() {
    note.title = titleController.text;
  }

  //Update description of Note object
  void updateDesc() {
    note.desc = descriptionController.text;
  }

  //Save data to database
  void _save() async {

    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if (note.id != null) {
      //Case 1: Update Operation
      result = await helper.updateNote(note);
    } else {
      //Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if(result != 0){
      _showAlertDialog('Status', "Note Saved Successfully");
    }else{
      _showAlertDialog('Status', "Problem in saving note");
    }
  }


  void _delete() async{

    moveToLastScreen();

    //Case 1: If user is trying to delete the NEW NOTE i.e. he has come to the
    //detail page by pressing the FAB of NoteList page
    if(note.id == null){
      _showAlertDialog("Status", "No note was deleted");
      return;
    }

    //Case 2: User is trying to delete the old note that already has a valid ID
    int result = await helper.deleteNote(note.id);
    if(result != 0){
      _showAlertDialog("Status", "Note deleted Successfully");
    }else{
      _showAlertDialog("Status", "Error occured while deleting the note");
    }
  }

  void _showAlertDialog(String title, String msg) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(msg),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog
    );
  }
}
