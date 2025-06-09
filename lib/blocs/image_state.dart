import 'dart:io';
import 'package:docexaaesthetic/models/GetUploadedImagesResponse.dart';
import 'package:docexaaesthetic/models/patientpost';
import 'package:equatable/equatable.dart';

class ImageState {
  final List<File> images; // Local images
  final List<UploadedFile> uploadedFiles; // Server images with metadata
  final bool isLoading;
  final String? error;

  const ImageState({
    this.images = const [],
    this.uploadedFiles = const [],
    this.isLoading = false,
    this.error,
  });

  ImageState copyWith({
    List<File>? images,
    List<UploadedFile>? uploadedFiles,
    bool? isLoading,
    String? error,
  }) {
    return ImageState(
      images: images ?? this.images,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasImages => images.isNotEmpty || uploadedFiles.isNotEmpty;
  int get totalImageCount => images.length + uploadedFiles.length;

  bool get isUploadInProgress => isLoading;

  @override
  List<Object?> get props => [images];
}
