class AccountDeletionResult {
  const AccountDeletionResult({
    required this.pending,
    required this.retainedFinancialRecords,
  });

  final bool pending;
  final bool retainedFinancialRecords;
}

class AccountDeletionException implements Exception {
  const AccountDeletionException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  bool get requiresReauthentication => code == 'REAUTH_REQUIRED';

  @override
  String toString() => message;
}

abstract interface class AccountRepository {
  Future<AccountDeletionResult> deleteAccount();
}
