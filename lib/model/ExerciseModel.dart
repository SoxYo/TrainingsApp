

class Exercise {
  final String id;
  final String title;
  final String category;
  final String thumbnail;
  final String duration;
  final DateTime timestamp;
  final int points;


  const Exercise({
    required this.id,
    required this.title,
    required this.category,
    required this.thumbnail,
    required this.duration,
    required this.timestamp,
    required this.points,
  });

}

final List<Exercise> videos = [
  Exercise(id: '12345', title: 'DEMO Exercise', category: 'cardio', duration: '30:09', timestamp: DateTime(2021,6,28), points: 300, thumbnail: 'assets/images/thumbnail_dummy.jpg'),
  Exercise(id: '12346', title: 'Cardio for Beginners', category: 'cardio', duration: '10:32', timestamp: DateTime(2021,6,28), points: 100, thumbnail: 'assets/images/running_dummy.jpg'),

];