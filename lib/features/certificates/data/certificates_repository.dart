import '../domain/certificate_detail.dart';
import '../domain/certificate_summary.dart';

abstract class CertificatesRepository {
  Future<List<CertificateSummary>> fetchCertificates();

  Future<CertificateDetail> fetchCertificateDetail(String certificateId);
}
