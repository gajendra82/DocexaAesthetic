class GetUploadedImagesResponse {
  final bool status;
  final String message;
  final UploadedImagesData? data;

  GetUploadedImagesResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory GetUploadedImagesResponse.fromJson(Map<String, dynamic> json) {
    return GetUploadedImagesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UploadedImagesData.fromJson(json['data'])
          : null,
    );
  }
}

class UploadedImagesData {
  final List<UploadedFile> uploadedFiles;

  UploadedImagesData({required this.uploadedFiles});

  factory UploadedImagesData.fromJson(Map<String, dynamic> json) {
    var files = <UploadedFile>[];
    if (json['uploaded_files'] != null) {
      files = List<UploadedFile>.from(
        json['uploaded_files'].map((f) => UploadedFile.fromJson(f)),
      );
    }
    return UploadedImagesData(uploadedFiles: files);
  }
}

class UploadedFile {
  final String fileName;
  final String url;
  final String? uploadedDate; // Add if available in response
  final String? fileSize; // Add if available in response

  UploadedFile({
    required this.fileName,
    required this.url,
    this.uploadedDate,
    this.fileSize,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadedFile &&
          runtimeType == other.runtimeType &&
          fileName == other.fileName &&
          url == other.url;

  @override
  int get hashCode => fileName.hashCode ^ url.hashCode;

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      fileName: json['file_name'] ?? '',
      url: json['url'] ?? '',
      uploadedDate: json['uploaded_date'],
      fileSize: json['file_size'],
    );
  }
}
