import 'package:dio/dio.dart';

import '../models/attempt_draft_model.dart';
import '../network/api_client.dart';
import 'attempt_draft_repository.dart';

class ApiAttemptDraftRepository implements AttemptDraftRepository {
  ApiAttemptDraftRepository(this._apiClient);

  final ApiClient _apiClient;

  Dio get _dio => _apiClient.dio;

  @override
  Future<AttemptDraft?> getDraft(String testId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/attempt-drafts',
      queryParameters: {'testId': testId, 'attemptType': 'REAL'},
    );
    final drafts = AttemptDraftListResponse.fromJson(
      response.data ?? {},
    ).drafts;
    return drafts.isEmpty ? null : drafts.first;
  }

  @override
  Future<List<AttemptDraft>> listDrafts() async {
    final response = await _dio.get<Map<String, dynamic>>('/attempt-drafts');
    return AttemptDraftListResponse.fromJson(response.data ?? {}).drafts;
  }

  @override
  Future<SaveAttemptDraftResult> saveDraft({
    required String testId,
    required String testName,
    required String category,
    required AttemptDraftState state,
    String attemptType = 'REAL',
    String? originalAttemptId,
    int? expectedVersion,
    AttemptDraftStatus status = AttemptDraftStatus.inProgress,
    String lastDevice = 'android',
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/attempt-drafts',
      data: {
        'testId': testId,
        'testName': testName,
        'category': category,
        'attemptType': attemptType,
        'originalAttemptId': originalAttemptId,
        'state': state.toJson(),
        'expectedVersion': expectedVersion,
        'status': _$AttemptDraftStatusEnumMap[status],
        'lastDevice': lastDevice,
      }..removeWhere((_, value) => value == null),
    );

    return SaveAttemptDraftResult.fromJson(response.data ?? {});
  }

  @override
  Future<void> deleteDraft(String draftId) async {
    await _dio.delete<void>('/attempt-drafts/$draftId');
  }

  @override
  Future<AttemptDraftSubmitResponse> submitAttempt({
    required String testId,
    required String testName,
    required String category,
    required int timeSpent,
    required List<AttemptDraftResponsePayload> responses,
    Map<String, bool> flags = const {},
    String attemptType = 'REAL',
    String? draftId,
    int? expectedDraftVersion,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/attempts',
      data: {
        'testId': testId,
        'testName': testName,
        'category': category,
        'attemptType': attemptType,
        'timeSpent': timeSpent,
        'responses': responses.map((item) => item.toJson()).toList(),
        'flags': flags,
        'draftId': draftId,
        'expectedDraftVersion': expectedDraftVersion,
      }..removeWhere((_, value) => value == null),
    );

    final data = response.data ?? {};
    return AttemptDraftSubmitResponse(attemptId: data['id']?.toString() ?? '');
  }
}

const _$AttemptDraftStatusEnumMap = {
  AttemptDraftStatus.inProgress: 'in_progress',
  AttemptDraftStatus.paused: 'paused',
};
