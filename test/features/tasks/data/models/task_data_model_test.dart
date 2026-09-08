import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_data_model.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';

void main() {
  group('TaskDataModel', () {
    final tJson = {
      'id': '101',
      'user_id': 'user_123',
      'title': 'Test Task',
      'description': 'Test Description',
      'is_completed': false,
      'due_date': '2026-09-10T10:00:00.000Z',
      'priority': 'High',
      'category': 'Work',
      'created_at': '2026-09-08T10:00:00.000Z',
      'updated_at': '2026-09-08T10:00:00.000Z',
    };

    test('should parse JSON correctly into TaskDataModel', () {
      final model = TaskDataModel.fromJson(tJson);

      expect(model.id, equals('101'));
      expect(model.userId, equals('user_123'));
      expect(model.title, equals('Test Task'));
      expect(model.description, equals('Test Description'));
      expect(model.isCompleted, isFalse);
      expect(model.dueDate, equals('2026-09-10T10:00:00.000Z'));
      expect(model.priority, equals('High'));
      expect(model.category, equals('Work'));
    });

    test('should convert TaskDataModel into TaskEntity correctly', () {
      final model = TaskDataModel.fromJson(tJson);
      final entity = model.toEntity();

      expect(entity, isA<TaskEntity>());
      expect(entity.id, equals('101'));
      expect(entity.userId, equals('user_123'));
      expect(entity.title, equals('Test Task'));
      expect(entity.isCompleted, isFalse);
      expect(entity.priority, equals('High'));
      expect(entity.category, equals('Work'));
      expect(entity.dueDate, equals(DateTime.parse('2026-09-10T10:00:00.000Z')));
    });

    test('should serialize TaskDataModel to JSON correctly', () {
      final model = TaskDataModel.fromJson(tJson);
      final jsonOutput = model.toJson();

      expect(jsonOutput['id'], equals('101'));
      expect(jsonOutput['user_id'], equals('user_123'));
      expect(jsonOutput['title'], equals('Test Task'));
      expect(jsonOutput['is_completed'], equals(false));
      expect(jsonOutput['priority'], equals('High'));
    });
  });
}
