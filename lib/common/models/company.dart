class Company {
  Company({required name}) : _name = name;

  String? _name;
  String get name => _name == null ? '' : _name!;
  set name(String name) {
    _name = name;
  }

  @override
  String toString() => name.toString();
}
