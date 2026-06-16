import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart' as app_providers;
import '../../domain/certificate_detail.dart';

final certificateDetailControllerProvider = FutureProvider.family
    .autoDispose<CertificateDetail, String>((ref, certificateId) {
      return ref
          .read(app_providers.certificatesRepositoryProvider)
          .fetchCertificateDetail(certificateId);
    });
