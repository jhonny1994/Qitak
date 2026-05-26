import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AppContractRepository strict contracts', () {
    test(
      'throws typed contract-unavailable for domain contract failures',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final prefs = await SharedPreferences.getInstance();
        final repo = AppContractRepository(
          SupabaseClient('http://127.0.0.1:9', 'test-anon-key'),
          prefs,
        );
        await expectLater(
          () => repo.fetchDomainCodes('listing_status'),
          throwsA(
            isA<Object>().having(
              (error) => error.toString(),
              'token',
              contains(AppErrorCode.contractUnavailable.token),
            ),
          ),
        );
      },
    );

    test(
      'throws typed contract-unavailable for policy contract failures',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final prefs = await SharedPreferences.getInstance();
        final repo = AppContractRepository(
          SupabaseClient('http://127.0.0.1:9', 'test-anon-key'),
          prefs,
        );
        await expectLater(
          () => repo.fetchPolicyOptions('buyer_dispute_reason_code'),
          throwsA(
            isA<Object>().having(
              (error) => error.toString(),
              'token',
              contains(AppErrorCode.contractUnavailable.token),
            ),
          ),
        );
      },
    );
  });
}
