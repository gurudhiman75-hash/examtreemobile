import 'package:dio/dio.dart';

import '../network/api_client.dart';
import 'account_repository.dart';

class ApiAccountRepository implements AccountRepository {
  const ApiAccountRepository(this._apiClient);

  static const confirmation = 'DELETE MY ACCOUNT';

  final ApiClient _apiClient;

  @override
  Future<AccountDeletionResult> deleteAccount() async {
    try {
      final response = await _apiClient.dio.delete<Map<String, dynamic>>(
        '/users/me',
        data: const {'confirmation': confirmation},
      );
      final data = response.data ?? const <String, dynamic>{};
      return AccountDeletionResult(
        pending: data['status'] == 'pending',
        retainedFinancialRecords: data['retainedFinancialRecords'] == true,
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      final map = data is Map
          ? Map<String, dynamic>.from(data)
          : const <String, dynamic>{};
      final code = map['code']?.toString().trim();
      final message = map['error']?.toString().trim();
      throw AccountDeletionException(
        code: code == null || code.isEmpty ? 'ACCOUNT_DELETION_FAILED' : code,
        message: message == null || message.isEmpty
            ? 'Account deletion could not be completed. Please try again.'
            : message,
      );
    }
  }
}
