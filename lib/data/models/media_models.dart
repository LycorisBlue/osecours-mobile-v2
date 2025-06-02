// lib/models/media_models.dart
import 'dart:io';

/// Modèle pour représenter un fichier média (photo ou vidéo)
class MediaFile {
  final File file;
  final bool isVideo;
  final String mimeType;
  final DateTime createdAt;

  MediaFile({required this.file, this.isVideo = false, required this.mimeType, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  /// Formats d'images acceptés
  static const List<String> acceptedImageFormats = ['jpg', 'jpeg', 'png'];

  /// Formats de vidéos acceptés
  static const List<String> acceptedVideoFormats = ['mp4', 'mov'];

  /// Taille maximale pour les images (5 MB)
  static const int maxImageSizeBytes = 5 * 1024 * 1024;

  /// Taille maximale pour les vidéos (10 MB)
  static const int maxVideoSizeBytes = 10 * 1024 * 1024;

  /// Durée maximale pour les vidéos (10 secondes)
  static const Duration maxVideoDuration = Duration(seconds: 10);

  /// Vérifie si le format de fichier est accepté
  static bool isFormatAccepted(String extension, bool isVideo) {
    final ext = extension.toLowerCase();
    return isVideo ? acceptedVideoFormats.contains(ext) : acceptedImageFormats.contains(ext);
  }

  /// Obtient le type MIME approprié selon l'extension
  static String getMimeType(String extension, bool isVideo) {
    final ext = extension.toLowerCase();
    if (isVideo) {
      switch (ext) {
        case 'mp4':
          return 'video/mp4';
        case 'mov':
          return 'video/quicktime';
        default:
          return 'video/$ext';
      }
    } else {
      switch (ext) {
        case 'jpg':
        case 'jpeg':
          return 'image/jpeg';
        case 'png':
          return 'image/png';
        default:
          return 'image/$ext';
      }
    }
  }

  /// Valide la taille du fichier selon son type
  Future<bool> isValidSize() async {
    try {
      final int fileSizeBytes = await file.length();
      final int maxSize = isVideo ? maxVideoSizeBytes : maxImageSizeBytes;
      return fileSizeBytes <= maxSize;
    } catch (e) {
      return false;
    }
  }

  /// Obtient la taille du fichier en bytes
  Future<int> getSizeInBytes() async {
    try {
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Obtient la taille du fichier formatée (ex: "2.5 MB")
  Future<String> getFormattedSize() async {
    final sizeBytes = await getSizeInBytes();

    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Vérifie si le fichier existe
  bool exists() {
    return file.existsSync();
  }

  /// Obtient l'extension du fichier
  String get extension {
    return file.path.split('.').last.toLowerCase();
  }

  /// Obtient le nom du fichier
  String get fileName {
    return file.path.split('/').last;
  }

  /// Crée une copie du MediaFile avec des propriétés modifiées
  MediaFile copyWith({File? file, bool? isVideo, String? mimeType, DateTime? createdAt}) {
    return MediaFile(
      file: file ?? this.file,
      isVideo: isVideo ?? this.isVideo,
      mimeType: mimeType ?? this.mimeType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MediaFile{fileName: $fileName, isVideo: $isVideo, mimeType: $mimeType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaFile && other.file.path == file.path && other.isVideo == isVideo && other.mimeType == mimeType;
  }

  @override
  int get hashCode {
    return file.path.hashCode ^ isVideo.hashCode ^ mimeType.hashCode;
  }
}

