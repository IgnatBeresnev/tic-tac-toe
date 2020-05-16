class Player {
  final String id;
  final String name;

  Player(this.id, this.name);

  Player.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}
