import 'package:docexaaesthetic/Repository/PatientRepository';
import 'package:docexaaesthetic/models/GetUploadedImagesResponse.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'image_event.dart';
import 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final PatientRepository patientRepository; // Instance of PatientRepository

  ImageBloc(this.patientRepository) : super(const ImageState()) {
    // on<SelectPatient>((event, emit) {
    //   emit(state.copyWith(selectedPatient: event.patient));
    // });

    on<AddImage>((event, emit) {
      // final updatedImages = List<File>.from(state.images)..add(event.image);
      // emit(state.copyWith(images: updatedImages));

      final updatedImages = [event.image, ...state.images];
      emit(state.copyWith(images: updatedImages));
    });

    on<ClearImages>((event, emit) {
      emit(state.copyWith(images: []));
    });

// Inside your ImageBloc class, in the event handler
    on<RemoveImage>((event, emit) {
      final newImages = List<File>.from(state.images);
      newImages.removeAt(event.index);
      emit(state.copyWith(images: newImages));
    });

    // on<UpdateImagesWithUrls>((event, emit) {
    //   emit(state.copyWith(
    //     uploadedImageUrls: event.imageUrls,
    //     images: [], // Clear the local files since they're now uploaded
    //   ));
    // });

    on<UpdateUploadedFiles>((event, emit) {
      // Create a new list with both existing and new files
      // final List<UploadedFile> updatedFiles = [
      //   ...state.uploadedFiles, // Keep existing files
      //   ...event.uploadedFiles, // Add new files
      // ];

      // // Remove any duplicates if needed (based on fileName or url)
      // final uniqueFiles = updatedFiles.toSet().toList();

      // // Emit new state with updated files
      // emit(state.copyWith(
      //   uploadedFiles: uniqueFiles,
      //   images: [], // Clear local images as they're now uploaded
      //   isLoading: false,
      // ));

      emit(state.copyWith(
        uploadedFiles: event.uploadedFiles,
        images: [], // Clear local images as they're now uploaded
        isLoading: false,
      ));

      // Print for debugging
      print('Total uploaded files: ${event.uploadedFiles.length}');
    });

    on<FetchUploadedImages>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final response = await patientRepository.getUploadedImages(
            event.patientNumber, event.doctorid);
        if (response.status) {
          emit(state.copyWith(
            uploadedFiles: response.data?.uploadedFiles ?? [],
            isLoading: false,
          ));
        } else {
          emit(state.copyWith(
            error: response.message,
            isLoading: false,
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          error: e.toString(),
          isLoading: false,
        ));
      }
    });

    // on<FetchUploadedImages>((event, emit) async {
    //   emit(state.copyWith(isLoading: true, error: null));
    //   try {
    //     final response = await patientRepository.getUploadedImages(
    //         event.patientNumber, event.doctorid);
    //     if (response.status) {
    //       emit(state.copyWith(
    //         uploadedFiles: response.data?.uploadedFiles ?? [],
    //         isLoading: false,
    //       ));
    //     } else {
    //       emit(state.copyWith(
    //         error: response.message,
    //         isLoading: false,
    //       ));
    //     }
    //   } catch (e) {
    //     emit(state.copyWith(
    //       error: e.toString(),
    //       isLoading: false,
    //     ));
    //   }
    // });

    // on<UpdateUploadedFiles>((event, emit) {
    //   // Combine existing uploaded files with new ones
    //   final List<UploadedFile> updatedFiles = [
    //     ...state.uploadedFiles,
    //     ...event.uploadedFiles,
    //   ];

    //   emit(state.copyWith(
    //     uploadedFiles: updatedFiles,
    //     images: [], // Clear local images as they're now uploaded
    //     isLoading: false,
    //   ));
  }
}
