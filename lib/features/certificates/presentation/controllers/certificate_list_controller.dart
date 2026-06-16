import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../domain/certificate_summary.dart';

final certificateListControllerProvider =
    FutureProvider.autoDispose<List<CertificateSummary>>((ref) {
      return ref
          .read(app_providers.certificatesRepositoryProvider)
          .fetchCertificates();
    });
