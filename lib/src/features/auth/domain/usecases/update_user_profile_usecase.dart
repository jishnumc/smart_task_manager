import 'package:smart_task_manager/src/features/auth/domain/entities/user_entity.dart';
import 'package:smart_task_manager/src/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  const UpdateUserProfileUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<UserEntity> call({
    required String name,
    String? themeMode,
  }) {
    return _authRepository.updateUserProfile(
      name: name,
      themeMode: themeMode,
    );
  }
}
