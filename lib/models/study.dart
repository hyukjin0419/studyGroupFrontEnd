import 'user.dart';

class Study {
  final int id;
  final String title;
  final List<User> members;

  Study({
    required this.id,
    required this.title,
    required this.members});
}
