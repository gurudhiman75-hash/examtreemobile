import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../auth/presentation/providers/auth_providers.dart';

class NetworkDiagnosticsScreen extends ConsumerStatefulWidget {
  const NetworkDiagnosticsScreen({super.key});

  @override
  ConsumerState<NetworkDiagnosticsScreen> createState() =>
      _NetworkDiagnosticsScreenState();
}

class _NetworkDiagnosticsScreenState
    extends ConsumerState<NetworkDiagnosticsScreen> {
  bool _running = false;
  List<_DiagnosticResult> _results = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (_running) return;
    setState(() {
      _running = true;
      _results = const [];
    });

    final results = <_DiagnosticResult>[];
    final directDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {'Accept': 'application/json'},
      ),
    );

    try {
      results.add(await _probeDirect(
        directDio,
        name: 'Render health',
        url: 'https://examtree-new.onrender.com/health',
      ));
      results.add(await _probeDirect(
        directDio,
        name: 'Direct catalogue',
        url: 'https://examtree-new.onrender.com/api/tests',
        requireList: true,
      ));

      final apiClient = ref.read(apiClientProvider);
      results.add(await _probeClientCatalogue(apiClient.dio));

      final auth = ref.read(firebaseAuthProvider);
      final user = auth.currentUser;
      results.add(
        _DiagnosticResult(
          name: 'Firebase session',
          ok: user != null,
          detail: user == null
              ? 'signed-out'
              : 'signed-in; emailVerified=${user.emailVerified}',
        ),
      );

      if (user == null) {
        results.add(const _DiagnosticResult(
          name: 'Firebase token',
          ok: false,
          skipped: true,
          detail: 'skipped: no signed-in Firebase user',
        ));
        results.add(const _DiagnosticResult(
          name: 'Canonical profile',
          ok: false,
          skipped: true,
          detail: 'skipped: sign in first, then run diagnostics again',
        ));
      } else {
        try {
          final token = await user.getIdToken();
          results.add(
            _DiagnosticResult(
              name: 'Firebase token',
              ok: token != null && token.trim().isNotEmpty,
              detail: token != null && token.trim().isNotEmpty
                  ? 'ID token available'
                  : 'ID token missing',
            ),
          );
        } on FirebaseAuthException catch (error) {
          results.add(_DiagnosticResult(
            name: 'Firebase token',
            ok: false,
            detail: 'firebase:${error.code}',
          ));
        } catch (error) {
          results.add(_DiagnosticResult(
            name: 'Firebase token',
            ok: false,
            detail: 'error:${error.runtimeType}',
          ));
        }

        results.add(await _probeProfile(apiClient.dio));
      }
    } finally {
      directDio.close(force: true);
    }

    if (!mounted) return;
    setState(() {
      _results = results;
      _running = false;
    });
  }

  Future<_DiagnosticResult> _probeDirect(
    Dio dio, {
    required String name,
    required String url,
    bool requireList = false,
  }) async {
    try {
      final response = await dio.get<Object?>(url);
      final data = response.data;
      final shapeOk = !requireList || data is List;
      final count = data is List ? '; count=${data.length}' : '';
      return _DiagnosticResult(
        name: name,
        ok: response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300 &&
            shapeOk,
        detail:
            'HTTP ${response.statusCode}; ${_safeUri(response.requestOptions.uri)}$count',
      );
    } catch (error) {
      return _failure(name, error);
    }
  }

  Future<_DiagnosticResult> _probeClientCatalogue(Dio dio) async {
    try {
      final response = await dio.get<List<dynamic>>('/tests');
      return _DiagnosticResult(
        name: 'App ApiClient catalogue',
        ok: response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300 &&
            response.data != null,
        detail:
            'HTTP ${response.statusCode}; ${_safeUri(response.requestOptions.uri)}; count=${response.data?.length ?? 0}',
      );
    } catch (error) {
      return _failure('App ApiClient catalogue', error);
    }
  }

  Future<_DiagnosticResult> _probeProfile(Dio dio) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/users/me');
      return _DiagnosticResult(
        name: 'Canonical profile',
        ok: response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300,
        detail:
            'HTTP ${response.statusCode}; ${_safeUri(response.requestOptions.uri)}',
      );
    } catch (error) {
      return _failure('Canonical profile', error);
    }
  }

  _DiagnosticResult _failure(String name, Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final data = error.response?.data;
      final code = data is Map ? data['code']?.toString() : null;
      final statusText = status == null ? 'no-http-status' : 'HTTP $status';
      final codeText = code == null || code.trim().isEmpty ? '' : '; code=$code';
      return _DiagnosticResult(
        name: name,
        ok: false,
        detail:
            '${error.type.name}; $statusText; ${_safeUri(error.requestOptions.uri)}$codeText',
      );
    }
    return _DiagnosticResult(
      name: name,
      ok: false,
      detail: 'error:${error.runtimeType}',
    );
  }

  String _safeUri(Uri uri) {
    final path = uri.path.isEmpty ? '/' : uri.path;
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}$path';
  }

  String _report() {
    final buffer = StringBuffer('ExamTree Android network diagnostics\n');
    for (final result in _results) {
      final status = result.skipped ? 'SKIP' : result.ok ? 'PASS' : 'FAIL';
      buffer.writeln('$status | ${result.name} | ${result.detail}');
    }
    return buffer.toString().trimRight();
  }

  Future<void> _copyReport() async {
    if (_results.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _report()));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Diagnostic report copied')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network diagnostics'),
        actions: [
          IconButton(
            tooltip: 'Run again',
            onPressed: _running ? null : _run,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'This screen checks the same production services used by the app. It never displays or copies your token or email address.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (_running)
            const LinearProgressIndicator()
          else if (_results.isEmpty)
            const Text('No diagnostic results yet.'),
          if (_results.isNotEmpty) ...[
            for (final result in _results)
              Card(
                child: ListTile(
                  leading: Icon(
                    result.skipped
                        ? Icons.remove_circle_outline
                        : result.ok
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                  ),
                  title: Text(result.name),
                  subtitle: SelectableText(result.detail),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _copyReport,
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy report'),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiagnosticResult {
  const _DiagnosticResult({
    required this.name,
    required this.ok,
    required this.detail,
    this.skipped = false,
  });

  final String name;
  final bool ok;
  final String detail;
  final bool skipped;
}
