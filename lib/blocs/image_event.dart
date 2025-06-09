import 'dart:io';

import 'package:docexaaesthetic/models/GetUploadedImagesResponse.dart';
import 'package:docexaaesthetic/models/patientpost';

abstract class ImageEvent {}

class SelectPatient extends ImageEvent {
  final Patientpost patient;
  SelectPatient(this.patient);
}

class AddImage extends ImageEvent {
  final File image;
  AddImage(this.image);
}

// class RemoveImage extends ImageEvent {
//   final int index;
//   final String fileName;

//   RemoveImage({
//     required this.index,
//     required this.fileName,
//   });
// }

class UpdateImagesWithUrls extends ImageEvent {
  final List<String> imageUrls;

  UpdateImagesWithUrls(this.imageUrls);
}

class FetchUploadedImages extends ImageEvent {
  final String patientNumber;
  final String doctorid;
  final bool isRefresh; // Optional: to handle refresh scenarios

  FetchUploadedImages({
    required this.patientNumber,
    required this.doctorid,
    this.isRefresh = false,
  });
}

// Event for successful fetch
class FetchUploadedImagesSuccess extends ImageEvent {
  final List<UploadedFile> uploadedFiles;
  final String message;

  FetchUploadedImagesSuccess({
    required this.uploadedFiles,
    required this.message,
  });
}

class UpdateUploadedFiles extends ImageEvent {
  final List<UploadedFile> uploadedFiles;

  UpdateUploadedFiles(this.uploadedFiles);
}

class RemoveImage extends ImageEvent {
  final int index;
  final String fileName;
  final bool isUploaded;
  final String? doctorId;
  final String? patientId;
  final String? patientNumber;

  RemoveImage({
    required this.index,
    required this.fileName,
    this.isUploaded = false,
    this.doctorId,
    this.patientId,
    this.patientNumber,
  });
}

class ClearImages extends ImageEvent {}
