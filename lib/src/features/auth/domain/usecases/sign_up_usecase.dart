import 'package:smart_task_manager/src/features/auth/domain/entities/user_entity.dart';
import 'package:smart_task_manager/src/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<UserEntity> call({
    required String email,
    required String password,
    required String name,
  }) {
    return _authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );
  }
}
