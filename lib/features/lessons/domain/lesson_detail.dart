class LessonDetail {
  const LessonDetail({
    required this.id,
    required this.title,
    required this.body,
    required this.progressLabel,
    required this.completionLabel,
    required this.video,
    required this.audio,
    required this.workbook,
    required this.relatedAssessment,
  });

  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    final media = _asMap(json['media']) ?? const <String, dynamic>{};

    return LessonDetail(
      id: _asString(json['id']) ?? _asString(json['slug']) ?? '',
      title: _asString(json['title']) ?? _asString(json['name']) ?? 'Lesson',
      body:
          _asString(json['content']) ??
          _asString(json['body']) ??
          _asString(json['description']) ??
          'Lesson content is ready for mobile rendering.',
      progressLabel:
          _asString(json['progress_label']) ??
          _asString(json['progress']) ??
          '--',
      completionLabel:
          _asString(json['completion_label']) ??
          _asString(json['completion_state']) ??
          _asString(json['status']) ??
          'In progress',
      video: LessonVideo.fromJson(
        _asMap(json['video']) ??
            _asMap(media['video']) ??
            _videoFromFlatJson(json) ??
            const <String, dynamic>{},
      ),
      audio: LessonAudio.fromJson(
        _asMap(json['audio']) ??
            _asMap(media['audio']) ??
            _audioFromFlatJson(json) ??
            const <String, dynamic>{},
      ),
      workbook: LessonWorkbook.fromJson(
        _asMap(json['workbook']) ??
            _asMap(json['file']) ??
            _asMap(media['workbook']) ??
            _workbookFromFlatJson(json) ??
            const <String, dynamic>{},
      ),
      relatedAssessment: LessonAssessment.fromJson(
        _asMap(json['assessment']) ??
            _asMap(json['related_assessment']) ??
            const <String, dynamic>{},
      ),
    );
  }

  final String id;
  final String title;
  final String body;
  final String progressLabel;
  final String completionLabel;
  final LessonVideo video;
  final LessonAudio audio;
  final LessonWorkbook workbook;
  final LessonAssessment relatedAssessment;
}

class LessonVideo {
  const LessonVideo({
    required this.title,
    required this.hlsUrl,
    required this.posterUrl,
  });

  factory LessonVideo.fromJson(Map<String, dynamic> json) {
    return LessonVideo(
      title:
          _asString(json['title']) ??
          _asString(json['label']) ??
          'Lesson video',
      hlsUrl:
          _asString(json['hls_url']) ??
          _asString(json['url']) ??
          _asString(json['stream_url']) ??
          '',
      posterUrl:
          _asString(json['poster']) ??
          _asString(json['thumbnail']) ??
          _asString(json['image']) ??
          '',
    );
  }

  final String title;
  final String hlsUrl;
  final String posterUrl;

  bool get isAvailable => hlsUrl.isNotEmpty;
}

class LessonAudio {
  const LessonAudio({required this.title, required this.url});

  factory LessonAudio.fromJson(Map<String, dynamic> json) {
    return LessonAudio(
      title:
          _asString(json['title']) ??
          _asString(json['label']) ??
          'Lesson audio',
      url: _asString(json['url']) ?? _asString(json['audio_url']) ?? '',
    );
  }

  final String title;
  final String url;

  bool get isAvailable => url.isNotEmpty;
}

class LessonWorkbook {
  const LessonWorkbook({required this.label, required this.url});

  factory LessonWorkbook.fromJson(Map<String, dynamic> json) {
    return LessonWorkbook(
      label:
          _asString(json['label']) ??
          _asString(json['title']) ??
          _asString(json['name']) ??
          'Workbook',
      url: _asString(json['url']) ?? _asString(json['file_url']) ?? '',
    );
  }

  final String label;
  final String url;

  bool get isAvailable => url.isNotEmpty;
}

class LessonAssessment {
  const LessonAssessment({
    required this.id,
    required this.title,
    required this.ctaLabel,
    required this.isAvailable,
  });

  factory LessonAssessment.fromJson(Map<String, dynamic> json) {
    return LessonAssessment(
      id: _asString(json['id']) ?? _asString(json['slug']) ?? '',
      title:
          _asString(json['title']) ??
          _asString(json['name']) ??
          'Related assessment',
      ctaLabel:
          _asString(json['cta_label']) ??
          _asString(json['action_label']) ??
          'Open assessment',
      isAvailable:
          _asBool(json['available']) ??
          _asBool(json['exists']) ??
          json.isNotEmpty,
    );
  }

  final String id;
  final String title;
  final String ctaLabel;
  final bool isAvailable;
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

bool? _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final normalized = value?.toString().toLowerCase();
  if (normalized == 'true') {
    return true;
  }
  if (normalized == 'false') {
    return false;
  }
  return null;
}

Map<String, dynamic>? _videoFromFlatJson(Map<String, dynamic> json) {
  final url =
      _asString(json['video_hls_url']) ??
      _asString(json['video_url']) ??
      _asString(json['hls_url']);
  if (url == null) {
    return null;
  }

  return {
    'hls_url': url,
    'thumbnail':
        _asString(json['video_thumbnail']) ?? _asString(json['thumbnail']),
  };
}

Map<String, dynamic>? _audioFromFlatJson(Map<String, dynamic> json) {
  final url = _asString(json['audio_url']) ?? _asString(json['audio']);
  if (url == null) {
    return null;
  }

  return {'url': url};
}

Map<String, dynamic>? _workbookFromFlatJson(Map<String, dynamic> json) {
  final url = _asString(json['workbook_url']) ?? _asString(json['file_url']);
  if (url == null) {
    return null;
  }

  return {
    'url': url,
    'label': _asString(json['workbook_label']) ?? _asString(json['file_name']),
  };
}
