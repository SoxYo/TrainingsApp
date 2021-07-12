class UserModel {
  String name;
  String imagePath;
  String email;
  List groups;
  String? currentGroup;

  UserModel( {
    required this.name,
    required this.imagePath,
    required this.email,
    required this.groups,
    required this.currentGroup
  });

}
