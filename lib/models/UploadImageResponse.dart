class UploadImageResponse {
  final bool status;
  final String message;
  final UploadImageData? data;

  UploadImageResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory UploadImageResponse.fromJson(Map<String, dynamic> json) {
    return UploadImageResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null ? UploadImageData.fromJson(json['data']) : null,
    );
  }
}

class UploadImageData {
  final List<UploadedFileresponse> uploadedFiles;

  UploadImageData({required this.uploadedFiles});

  factory UploadImageData.fromJson(Map<String, dynamic> json) {
    var files = <UploadedFileresponse>[];
    if (json['uploaded_files'] != null) {
      files = List<UploadedFileresponse>.from(
        json['uploaded_files'].map((f) => UploadedFileresponse.fromJson(f)),
      );
    }
    return UploadImageData(uploadedFiles: files);
  }
}

class UploadedFileresponse {
  final String fileName;
  final String url;

  UploadedFileresponse({required this.fileName, required this.url});

  factory UploadedFileresponse.fromJson(Map<String, dynamic> json) {
    return UploadedFileresponse(
      fileName: json['file_name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
