class Note {
  int _id;
  int _priotiry;
  String _title, _desc, _date;

  Note(this._title, this._date, this._priotiry,  [this._desc]);

  Note.withId(this._id, this._priotiry, this._title, this._date, [this._desc]);

  get date => _date;

  get desc => _desc;

  String get title => _title;

  int get priotiry => _priotiry;

  int get id => _id;

  set date(value) {
    _date = value;
  }

  set desc(value) {
    _desc = value;
  }

  set title(String value) {
    _title = value;
  }

  set priotiry(int value) {
    if (value >= 1 && value <= 2) {
      _priotiry = value;
    }
  }

  // Convert a Note Object into a MAP object

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['desc'] = _desc;
    map['priority'] = _priotiry;
    map['date'] = _date;

    return map;
  }

  //Extract a Note Object from a MAP obeject
  Note.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._desc = map['desc'];
    this._priotiry = map['priority'];
    this._date = map['date'];
  }
}
