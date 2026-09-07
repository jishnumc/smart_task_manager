import 'package:smart_task_manager/src/features/auth/domain/entities/user_entity.dart';
import 'package:smart_task_manager/src/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<UserEntity?> call() {
    return _authRepository.getCurrentUser();
  }
}
