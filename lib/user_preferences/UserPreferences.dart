import 'package:keep_on_moving/model/UserModel.dart';

class UserPreferences {
  static var dummyUser = UserModel(
      imagePath: 'assets/images/profile_dummy.png',
          //'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=333&q=80',
      name: 'Sporty Bird',
      email: 'melanie.willbold@web.de',
      currentGroup: "team",
      groups: []);
}
