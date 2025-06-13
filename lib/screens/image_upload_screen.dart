import 'dart:io';
import 'package:docexaaesthetic/Repository/PatientRepository';
import 'package:docexaaesthetic/blocs/PatientEvent.dart';
import 'package:docexaaesthetic/blocs/PatientState.dart';
import 'package:docexaaesthetic/blocs/PatientBloc.dart';
import 'package:docexaaesthetic/models/GetUploadedImagesResponse.dart';
import 'package:docexaaesthetic/models/UploadImageResponse.dart';
import 'package:docexaaesthetic/screens/ProfilePage.dart';

import 'package:docexaaesthetic/screens/full_image_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/patientget.dart';
import '../blocs/image_bloc.dart';
import '../blocs/image_event.dart';
import '../blocs/image_state.dart';
import '../services/api_service.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final picker = ImagePicker();
  final apiService = ApiService();
  late final PatientRepository patientRepository;
  bool _isSubmitting = false;

  // Pagination variables
  final int _perPage = 10;
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoading = false;
  final List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];

  // Scroll controller for lazy loading
  final ScrollController _scrollController = ScrollController();
  String doctor_id = "70688"; // Replace with actual doctor ID

  @override
  void initState() {
    super.initState();
    patientRepository = PatientRepository(apiService);
    _scrollController.addListener(_scrollListener);

    // Update your API calls to include userLogin and timestamp

    _loadUserData();
    context.read<ImageBloc>().stream.listen((state) {
      if (state.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args['establishment_user_map_id'] != null) {
        setState(() {
          doctor_id = args['establishment_user_map_id'].toString();
        });
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final establishmentUserMapId =
            prefs.getInt('establishment_user_map_id');

        if (establishmentUserMapId != null) {
          setState(() {
            doctor_id = establishmentUserMapId.toString();
          });
        } else {
          throw Exception('No establishment user map ID found');
        }
      }

      // Once we have the doctor_id, load the patients
      _loadMorePatients();
    } catch (e) {
      print('Error loading establishment_user_map_id: $e');
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Error loading user data: $e'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      // }
    } finally {
      // Fetch images for the selected patient if any
      // _fetchImagesForSelectedPatient();
    }
  }

  void _fetchImagesForSelectedPatient() {
    final patientState = context.read<PatientBloc>().state;
    if (patientState is PatientLoadSuccess &&
        patientState.selectedPatient != null) {
      context.read<ImageBloc>().add(
            FetchUploadedImages(
                patientNumber: patientState.selectedPatient!.mobileNo!,
                doctorid: doctor_id),
          );
    }
  }

  Future<void> _loadMorePatients() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newPatients = await patientRepository.getPatients(
        userId: int.parse(doctor_id), // Replace with actual user ID
        page: _currentPage,
        perPage: _perPage,
      );

      setState(() {
        if (newPatients.data!.patient!.isEmpty) {
          _hasMoreData = false;
        } else {
          _patients.addAll(newPatients.data!.patient!);
          _filteredPatients = List.from(_patients);
          _currentPage++;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading patients: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePatients();
    }
  }

  void _filterPatients(String query) {
    setState(() {
      _filteredPatients = _patients
          .where(
            (p) => ('${p.patientName} ${p.mobileNo}')
                .toLowerCase()
                .contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);

        // Add to local images immediately
        setState(() {
          context.read<ImageBloc>().add(
                AddImage(imageFile),
              );
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Future<void> _pickImage(BuildContext context, ImageSource source) async {
  //   final pickedFile = await picker.pickImage(source: source);
  //   if (pickedFile != null) {
  //     context.read<ImageBloc>().add(AddImage(File(pickedFile.path)));
  //   }
  // }

  // ... (keep other code the same until _openPatientSelector method)

  // ... (keep other code the same until _openPatientSelector method)

  void _openPatientSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<PatientBloc>(),
        child: _PatientSelectorSheet(
            scrollController: _scrollController,
            onPatientSelected: (Patient patient) {
              if (patient.mobileNo != null) {
                context.read<ImageBloc>().add(
                      FetchUploadedImages(
                        patientNumber: patient.mobileNo!,
                        doctorid: doctor_id,
                      ),
                    );
              }
            }),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _hasMoreData
                ? ElevatedButton(
                    onPressed: _loadMorePatients,
                    child: const Text('Load More'),
                  )
                : const Text('No more patients'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Image Upload",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )),
        backgroundColor: Colors.teal.shade600,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.account_circle, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          return BlocBuilder<PatientBloc, PatientState>(
            builder: (context, patientState) {
              // final patient = PatientState.selectedPatient;
              final patient = patientState is PatientLoadSuccess
                  ? patientState.selectedPatient
                  : null;
              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (patient != null)
                        Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.teal.shade50, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _openPatientSelector,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.teal.shade100,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          patient.patientName![0].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            patient.patientName ?? 'No Name',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${patient.gender == 1 ? 'Male' : 'Female'}, ${patient.age ?? 'N/A'} years',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.phone,
                                                size: 16,
                                                color: Colors.teal.shade300,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                patient.mobileNo ?? 'No Mobile',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              const SizedBox(width: 4),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: Colors.teal.shade300,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                patient.lastAppointmentDate !=
                                                        null
                                                    ? 'Last Visit: ${patient.lastAppointmentDate}'
                                                    : 'No Last Visit',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.edit,
                                      color: Colors.teal.shade300,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        InkWell(
                          onTap: _openPatientSelector,
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.symmetric(
                              vertical: 32,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.teal.shade100,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_add,
                                  size: 32,
                                  color: Colors.teal.shade300,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Select Patient',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.teal.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildImageSourceButton(
                              context,
                              Icons.camera_alt,
                              'Camera',
                              ImageSource.camera,
                            ),
                            Container(
                              width: 1,
                              height: 36,
                              color: Colors.grey.shade200,
                            ),
                            _buildImageSourceButton(
                              context,
                              Icons.photo_library,
                              'Gallery',
                              ImageSource.gallery,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (state.images.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Selected Images (${state.images.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: patient != null
                            ? _buildImageGrid(
                                state,
                                patient.mobileNo ?? '',
                                patient.patientId is int
                                    ? patient.patientId as int
                                    : 0)
                            : const Center(
                                child: Text(
                                  'Please select a patient first',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  if (state.images.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade600,
                              Colors.teal.shade800,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: (patientState is PatientLoadSuccess &&
                                    patientState.selectedPatient != null &&
                                    !_isSubmitting)
                                ? () async {
                                    setState(() {
                                      _isSubmitting = true;
                                    });
                                    try {
                                      final selectedPatient =
                                          patientState.selectedPatient!;
                                      final doctorId =
                                          doctor_id; // Replace or fetch dynamically
                                      final patientId =
                                          selectedPatient.patientId.toString();
                                      final patientNumber =
                                          selectedPatient.mobileNo;

                                      final patient =
                                          patientState is PatientLoadSuccess
                                              ? patientState
                                                  .selectedPatient!.mobileNo
                                              : null;

                                      // Upload images and get response
                                      final GetUploadedImagesResponse response =
                                          await patientRepository
                                              .uploadPatientImages(
                                        imageFiles: state.images,
                                        doctorId: doctorId,
                                        patientId: patientId,
                                        patientNumber: patientNumber!,
                                      );

                                      if (context.mounted) {
                                        if (response.status) {
                                          // Success case
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(response.message),
                                              backgroundColor: Colors.green,
                                            ),
                                          );

                                          // Update uploaded files in state - this will automatically refresh the UI
                                          if (response.data?.uploadedFiles
                                                  .isNotEmpty ??
                                              false) {
                                            // Create a new UpdateUploadedFiles event with the new files
                                            context.read<ImageBloc>().add(
                                                  UpdateUploadedFiles(
                                                    List<UploadedFile>.from(
                                                        response.data!
                                                            .uploadedFiles),
                                                  ),
                                                );

                                            // Print for debugging
                                            print(
                                                'New files being added: ${response.data!.uploadedFiles.length}');
                                          }

                                          // If there are uploaded files, update the UI with their URLs
                                          else {
                                            // If no files were uploaded, clear the images
                                            context
                                                .read<ImageBloc>()
                                                .add(ClearImages());
                                          }
                                        } else {
                                          // Error case
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(response.message),
                                              backgroundColor: Colors.red,
                                              duration:
                                                  const Duration(seconds: 5),
                                              action: SnackBarAction(
                                                label: 'Dismiss',
                                                textColor: Colors.white,
                                                onPressed: () {
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                },
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error uploading images: $e'),
                                            backgroundColor: Colors.red,
                                            duration:
                                                const Duration(seconds: 5),
                                            action: SnackBarAction(
                                              label: 'Dismiss',
                                              textColor: Colors.white,
                                              onPressed: () {
                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentSnackBar();
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      setState(() {
                                        _isSubmitting = false;
                                      });
                                    }
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isSubmitting)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.cloud_upload,
                                      color: Colors.white,
                                    ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isSubmitting
                                        ? 'Uploading...'
                                        : 'Submit ${state.images.length} Image${state.images.length > 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImageGrid(
      ImageState state, String patientNumber, int patientId) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            ElevatedButton(
              onPressed: () {
                context.read<ImageBloc>().add(
                      FetchUploadedImages(
                        patientNumber: patientNumber,
                        doctorid: doctor_id,
                        isRefresh: true,
                      ),
                    );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!state.hasImages && state.images.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No images available',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ImageBloc>().add(
              FetchUploadedImages(
                patientNumber: patientNumber,
                doctorid: doctor_id,
                isRefresh: true,
              ),
            );
      },
      child: state.totalImageCount == 0
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No images available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              // Update itemCount to handle both local and uploaded images separately
              itemCount:
                  state.images.length + (state.uploadedFiles?.length ?? 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                // Show local images first

                try {
                  if (index < state.images.length) {
                    // Local images section
                    return _buildImageItem(context,
                        isLocalFile: true,
                        index: index,
                        state: state,
                        patientnumber: patientNumber,
                        patientid: patientId);
                  } else {
                    // Handle uploaded images
                    final uploadedIndex = index - state.images.length;
                    return _buildImageItem(context,
                        isLocalFile: false,
                        index: uploadedIndex,
                        state: state,
                        patientnumber: patientNumber,
                        patientid: patientId);
                  }
                } catch (e) {
                  print('Error building image item at index $index: $e');
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }

  Widget _buildImageItem(
    BuildContext context, {
    required bool isLocalFile,
    required int index,
    required ImageState state,
    required String patientnumber,
    required int patientid,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isLocalFile)
                  // Local image
                  Image.file(
                    state.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading local image: $error');
                      return _buildErrorContainer();
                    },
                  )
                else
                  // Uploaded image
                  Image.network(
                    state.uploadedFiles[index].url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading network image: $error');
                      return _buildErrorContainer();
                    },
                  ),

                // Controls overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(isLocalFile ? Icons.edit : Icons.edit_note,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullImageEditorScreen(
                                  image: isLocalFile
                                      ? state.images[index]
                                      : state.uploadedFiles[index].url,
                                  uploadedDate: isLocalFile
                                      ? DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(DateTime.now())
                                      : state.uploadedFiles[index].uploadedDate,
                                  patientNumber: patientnumber,
                                  patientId: patientid,
                                  doctorId: doctor_id,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  final bool? confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Delete Image'),
                                        content: const Text(
                                            'Are you sure you want to delete this image?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true && context.mounted) {
                                    if (isLocalFile) {
                                      context.read<ImageBloc>().add(
                                            RemoveImage(
                                              index: index,
                                              fileName: p.basename(
                                                  state.images[index].path),
                                              isUploaded: false,
                                            ),
                                          );
                                    } else {
                                      context.read<ImageBloc>().add(
                                            RemoveImage(
                                              index: index,
                                              fileName: state
                                                  .uploadedFiles[index]
                                                  .fileName,
                                              isUploaded: true,
                                              doctorId: doctor_id,
                                              patientId: patientid.toString(),
                                              patientNumber: patientnumber,
                                            ),
                                          );
                                    }
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildImageSourceButton(
    BuildContext context,
    IconData icon,
    String label,
    ImageSource source,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickImage(context, source),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.teal.shade600,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.teal.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientSelectorSheet extends StatelessWidget {
  final ScrollController scrollController;
  final Function(Patient) onPatientSelected; // Add this callback

  const _PatientSelectorSheet({
    Key? key,
    required this.scrollController,
    required this.onPatientSelected, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientBloc, PatientState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Search header with padding
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or mobile',
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onChanged: (query) {
                    context.read<PatientBloc>().add(FilterPatientsEvent(query));
                  },
                ),
              ),
              Expanded(
                child: _buildPatientList(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatientList(BuildContext context, PatientState state) {
    if (state is PatientLoadInProgress) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PatientLoadFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error),
            ElevatedButton(
              onPressed: () {
                context.read<PatientBloc>().add(const FetchPatientsEvent());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is PatientLoadSuccess) {
      final filteredPatients = state.searchQuery.isEmpty
          ? state.patients
          : state.patients
              .where((patient) =>
                  (patient.patientName?.toLowerCase() ?? '')
                      .contains(state.searchQuery.toLowerCase()) ||
                  (patient.mobileNo?.toLowerCase() ?? '')
                      .contains(state.searchQuery.toLowerCase()))
              .toList();

      return RefreshIndicator(
        onRefresh: () async {
          context
              .read<PatientBloc>()
              .add(const FetchPatientsEvent(isRefresh: true));
        },
        child: ListView.builder(
          controller: scrollController,
          itemCount: filteredPatients.length + (state.hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= filteredPatients.length) {
              if (!state.hasMoreData) return const SizedBox();

              context.read<PatientBloc>().add(const FetchMorePatientsEvent());
              return const Center(child: CircularProgressIndicator());
            }

            final patient = filteredPatients[index];
            return _buildPatientItem(context, patient);
          },
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildPatientItem(BuildContext context, Patient patient) {
    String getInitial() {
      final name = patient.patientName;
      if (name == null || name.isEmpty) return '';
      return name[0].toUpperCase();
    }

    String getGenderText() {
      return patient.gender == 1 ? 'Male' : 'Female';
    }

    return InkWell(
      onTap: () {
        // Here we pass the existing Patient object
        context.read<PatientBloc>().add(SelectPatientEvent(patient));
        onPatientSelected(patient); // Call the callback

        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  getInitial(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.patientName ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${getGenderText()}, ${patient.age ?? 'N/A'} years',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 14,
                        color: Colors.teal.shade300,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        patient.mobileNo ?? 'No Mobile',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (patient.lastAppointmentDate != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.teal.shade300,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Last Visit: ${patient.lastAppointmentDate}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
