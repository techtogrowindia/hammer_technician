import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/features/kyc/presentation/stepper/kyc_stepper_models.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class KycDocumentPicker {
  static Future<File> addWatermark(File imageFile) async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (_) {
      position = Position(
        latitude: 0,
        longitude: 0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
    final bytes = await imageFile.readAsBytes();
    img.Image image = img.decodeImage(bytes)!;
    if (image.width > 1080) {
      image = img.copyResize(image, width: 1080);
    }
    final text =
        "Lat: ${position.latitude.toStringAsFixed(5)}, "
        "Lng: ${position.longitude.toStringAsFixed(5)}\n"
        "${DateTime.now()}";
    final padding = 16;
    final barHeight = 90;
    img.fillRect(
      image,
      x1: 0,
      y1: image.height - barHeight,
      x2: image.width,
      y2: image.height,
      color: img.ColorRgb8(0, 0, 0),
    );
    img.drawString(
      image,
      text,
      font: img.arial24,
      x: padding,
      y: image.height - barHeight + 20,
      color: img.ColorRgb8(255, 255, 255),
    );
    final dir = await getTemporaryDirectory();
    final outFile = File(
      '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await outFile.writeAsBytes(img.encodeJpg(image, quality: 85));
    return outFile;
  }

  static bool validateFile(
    File file,
    String key,
    void Function(String) onError,
  ) {
    final ext = file.path.split('.').last.toLowerCase();
    final sizeMB = file.lengthSync() / (1024 * 1024);
    if (key == "bank_statement" ||
        key == "gst_document" ||
        key.contains("certificate_file")) {
      if (!['pdf', 'jpg', 'jpeg', 'png'].contains(ext)) {
        onError("Only PDF or Image allowed");
        return false;
      }
      if (sizeMB > 5) {
        onError("File size must be under 5 MB");
        return false;
      }
    } else {
      if (!['jpg', 'jpeg', 'png'].contains(ext)) {
        onError("Only JPG / PNG images allowed");
        return false;
      }
      if (sizeMB > 5) {
        onError("Image must be under 5 MB");
        return false;
      }
    }
    return true;
  }

  static Future<void> pickPassportPhoto({
    required ImagePicker picker,
    required void Function(File) onPicked,
    required void Function(String) onError,
  }) async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (image == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 3.5, ratioY: 4.5),
      compressQuality: 95,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: AppColors.primaryAmber,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(),
          ],
        ),
      ],
    );

    if (cropped == null) return;

    final watermarked = await addWatermark(File(cropped.path));
    onPicked(watermarked);
  }

  static Future<void> showDocumentSourceSheet({
    required BuildContext context,
    required String key,
    required ImagePicker picker,
    required bool Function(File file, String key) validateFile,
    required void Function(File) onFilePicked,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.document_scanner,
                  color: AppColors.primaryAmber,
                ),
                title: const Text("Scan Document"),
                onTap: () async {
                  Navigator.pop(context);
                  List<String>? images = await CunningDocumentScanner.getPictures(
                    isGalleryImportAllowed: false,
                  );
                  if (images == null || images.isEmpty) return;
                  final file = File(images.first);
                  if (validateFile(file, key)) onFilePicked(file);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryAmber,
                ),
                title: const Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (photo == null) return;
                  final file = File(photo.path);
                  if (validateFile(file, key)) onFilePicked(file);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryAmber,
                ),
                title: const Text("Choose from Gallery / Files"),
                onTap: () async {
                  Navigator.pop(context);
                  File? file;
                  if (key == "bank_statement" ||
                      key == "gst_document" ||
                      key.contains("certificate_file")) {
                    final res = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                    );
                    if (res == null) return;
                    file = File(res.files.single.path!);
                  } else {
                    final res = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (res == null) return;
                    file = File(res.path);
                  }
                  if (validateFile(file, key)) {
                    onFilePicked(file);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<List<File>> pickFiles(BuildContext context) async {
    List<File> result = [];
    final picker = ImagePicker();

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.document_scanner,
                  color: AppColors.primaryAmber,
                ),
                title: const Text("Scan Documents"),
                onTap: () async {
                  Navigator.pop(context);
                  List<String>? images = await CunningDocumentScanner.getPictures(
                    isGalleryImportAllowed: true,
                  );
                  if (images != null) {
                    result = images.map((e) => File(e)).toList();
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryAmber,
                ),
                title: const Text("Take Multiple Photos"),
                onTap: () async {
                  Navigator.pop(context);
                  // ImagePicker only picks one at a time for Camera
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (photo != null) result = [File(photo.path)];
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryAmber,
                ),
                title: const Text("Choose from Gallery / Files"),
                onTap: () async {
                  Navigator.pop(context);
                  // First try FilePicker for multiple files (supports PDF/Images)
                  final res = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                    allowMultiple: true,
                  );
                  if (res != null && res.files.isNotEmpty) {
                    result = res.files.map((f) => File(f.path!)).toList();
                  } else {
                    // Fallback to pickMultiImage if FilePicker fails or returns empty
                    final List<XFile> images = await picker.pickMultiImage();
                    if (images.isNotEmpty) {
                      result = images.map((e) => File(e.path)).toList();
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
    return result;
  }
  static Future<List<File>> pickFromCamera(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo != null) return [File(photo.path)];
    return [];
  }

  static Future<List<File>> pickFromGallery(BuildContext context) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (res != null && res.files.isNotEmpty) {
      return res.files.map((f) => File(f.path!)).toList();
    }
    return [];
  }
}
