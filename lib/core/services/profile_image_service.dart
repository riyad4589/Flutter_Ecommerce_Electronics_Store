import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfileImageService {
  final ImagePicker _picker = ImagePicker();

  /// Sélectionner une image depuis la galerie
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
      return null;
    }
  }

  /// Prendre une photo avec la caméra
  Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (photo == null) return null;

      return File(photo.path);
    } catch (e) {
      print('Erreur lors de la prise de photo: $e');
      return null;
    }
  }

  /// Sauvegarder l'image dans le dossier de l'application
  Future<String> saveProfileImage(File imageFile, String userId) async {
    try {
      // Obtenir le dossier de documents de l'application
      final appDir = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory('${appDir.path}/profile_images');

      // Créer le dossier s'il n'existe pas
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      // Créer le nom du fichier avec l'ID utilisateur
      final fileName = 'profile_$userId${path.extension(imageFile.path)}';
      final savedImage = File('${profileImagesDir.path}/$fileName');

      // Copier l'image
      await imageFile.copy(savedImage.path);

      return savedImage.path;
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'image: $e');
      rethrow;
    }
  }

  /// Supprimer l'image de profil
  Future<void> deleteProfileImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'image: $e');
    }
  }

  /// Obtenir le chemin de l'image de profil
  Future<String?> getProfileImagePath(String userId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory('${appDir.path}/profile_images');

      if (!await profileImagesDir.exists()) {
        return null;
      }

      // Chercher le fichier de profil pour cet utilisateur
      final files = await profileImagesDir.list().toList();
      for (var file in files) {
        if (file.path.contains('profile_$userId')) {
          return file.path;
        }
      }

      return null;
    } catch (e) {
      print('Erreur lors de la récupération du chemin de l\'image: $e');
      return null;
    }
  }
}
