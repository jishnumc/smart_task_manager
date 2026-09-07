abstract class TaskOptionsData {
  /// Structured JSON data representation.
  static const Map<String, dynamic> rawJson = {
    'priorities': ['Low', 'Medium', 'High'],
    'categories': [
      'Personal',
      'Work',
      'Shopping',
      'Health',
      'Finance',
      'Education',
      'Other',
    ],
    'sample_task': {
      'title': 'Buy Groceries',
      'description': 'Milk, Bread, Eggs, Vegetables',
      'is_completed': false,
      'due_date': '2026-02-15T19:00:00',
      'priority': 'Medium',
      'category': 'Personal',
    },
  };

  static const List<String> priorities = ['Low', 'Medium', 'High'];

  static const List<String> categories = [
    'Personal',
    'Work',
    'Shopping',
    'Health',
    'Finance',
    'Education',
    'Other',
  ];

  static const Map<String, dynamic> sampleTask = {
    'title': 'Buy Groceries',
    'description': 'Milk, Bread, Eggs, Vegetables',
    'is_completed': false,
    'due_date': '2026-02-15T19:00:00',
    'priority': 'Medium',
    'category': 'Personal',
  };
}
