class Company {
  Company({required this.name});
  Company copyWith({name}) {
    name ??= this.name;
    return Company(name: name);
  }

  final String name;

  @override
  String toString() => name.toString();
}
