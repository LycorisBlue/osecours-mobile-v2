// lib/core/constants/icons.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;

class IconManager {
  // Icônes courantes définies pour les deux plateformes
  static const Map<String, IconData> _materialIcons = {
    'home': Icons.home,
    'settings': Icons.settings,
    'back': Icons.arrow_back,
    'menu': Icons.menu,
    'search': Icons.search,
    'add': Icons.add,
    'delete': Icons.delete,
    'edit': Icons.edit,
    'notifications': Icons.notifications,
    'profile': Icons.person,
    'logout': Icons.logout,
    'email': Icons.email_outlined,
    'phone': Icons.phone_outlined,
    'password': Icons.lock_outline,
    'visibility_on': Icons.visibility,
    'visibility_off': Icons.visibility_off,
    'check': Icons.check_circle,
    'check_outline': Icons.check_circle_outline,
    'camera_alt': Icons.camera_alt,
    'camera_alt_outlined': Icons.camera_alt_outlined,
    'photo_camera': Icons.photo_camera,
    'photo_camera_outlined': Icons.photo_camera_outlined,
    'photo_library': Icons.photo_library,
    'photo_library_outlined': Icons.photo_library_outlined,
    'cloud_upload': Icons.cloud_upload,
    'cloud_upload_outlined': Icons.cloud_upload_outlined,
    'upload_file': Icons.upload_file,
    'insert_drive_file': Icons.insert_drive_file,
    'insert_drive_file_outlined': Icons.insert_drive_file_outlined,
    'category_outlined': Icons.category_outlined,
    'title_outlined': Icons.title_outlined,
    'description_outlined': Icons.description_outlined,
    'location_on_outlined': Icons.location_on_outlined,
    'arrow_forward': Icons.arrow_forward,
    'arrow_back': Icons.arrow_back,
    'check_circle_outline': Icons.check_circle_outline,
    'info_outline': Icons.info_outline,
    'history': Icons.history,
    'calendar_today': Icons.calendar_today,
    'link': Icons.link,
    'close': Icons.close,
    'lightbulb_outline': Icons.lightbulb_outline,
    'message': Icons.message,
    'download': Icons.download,
    'share': Icons.share,
    'pending_outlined': Icons.pending_outlined,
    'task_alt': Icons.task_alt,
    'attach_file': Icons.attach_file,
    'refresh': Icons.refresh,
    'lock_outline': Icons.lock_outline,
    'school': Icons.school,
    'insert_chart': Icons.insert_chart,
  };

  static const Map<String, IconData> _cupertinoIcons = {
    'home': CupertinoIcons.home,
    'settings': CupertinoIcons.settings,
    'back': CupertinoIcons.back,
    'menu': CupertinoIcons.bars,
    'search': CupertinoIcons.search,
    'add': CupertinoIcons.add,
    'delete': CupertinoIcons.delete,
    'edit': CupertinoIcons.pencil,
    'notifications': CupertinoIcons.bell,
    'profile': CupertinoIcons.profile_circled,
    'logout': CupertinoIcons.square_arrow_left,
    'email': CupertinoIcons.mail,
    'phone': CupertinoIcons.phone,
    'password': CupertinoIcons.lock,
    'visibility_on': CupertinoIcons.eye,
    'visibility_off': CupertinoIcons.eye_slash,
    'check': CupertinoIcons.check_mark_circled,
    'check_outline': CupertinoIcons.check_mark_circled,
    'camera_alt': CupertinoIcons.camera,
    'camera_alt_outlined': CupertinoIcons.camera,
    'photo_camera': CupertinoIcons.camera,
    'photo_camera_outlined': CupertinoIcons.camera,
    'photo_library': CupertinoIcons.photo,
    'photo_library_outlined': CupertinoIcons.photo,
    'cloud_upload': CupertinoIcons.cloud_upload,
    'cloud_upload_outlined': CupertinoIcons.cloud_upload,
    'upload_file': CupertinoIcons.doc_text,
    'insert_drive_file': CupertinoIcons.doc,
    'insert_drive_file_outlined': CupertinoIcons.doc,
    'category_outlined': CupertinoIcons.tag,
    'title_outlined': CupertinoIcons.textformat,
    'description_outlined': CupertinoIcons.doc_text,
    'location_on_outlined': CupertinoIcons.location,
    'arrow_forward': CupertinoIcons.arrow_right,
    'arrow_back': CupertinoIcons.arrow_left,
    'check_circle_outline': CupertinoIcons.checkmark_circle,
    'info_outline': CupertinoIcons.info,
    'history': CupertinoIcons.clock,
    'calendar_today': CupertinoIcons.calendar,
    'link': CupertinoIcons.link,
    'close': CupertinoIcons.xmark,
    'lightbulb_outline': CupertinoIcons.lightbulb,
    'message': CupertinoIcons.conversation_bubble,
    'download': CupertinoIcons.arrow_down_circle,
    'share': CupertinoIcons.share,
    'pending_outlined': CupertinoIcons.clock,
    'task_alt': CupertinoIcons.checkmark_seal,
    'attach_file': CupertinoIcons.paperclip,
    'refresh': CupertinoIcons.refresh,
    'lock_outline': CupertinoIcons.lock,
    'school': CupertinoIcons.book,
    'insert_chart': CupertinoIcons.chart_bar,
  };

  /// Récupère l'icône en fonction de la plateforme
  static Icon getIcon(String iconName, {Color? color, double? size}) {
    final IconData iconData =
        defaultTargetPlatform == TargetPlatform.iOS
            ? _cupertinoIcons[iconName] ?? _materialIcons[iconName]!
            : _materialIcons[iconName] ?? _cupertinoIcons[iconName]!;

    return Icon(iconData, color: color, size: size);
  }

  /// Récupère uniquement les données de l'icône (utile pour personnalisation)
  static IconData getIconData(String iconName) {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _cupertinoIcons[iconName] ?? _materialIcons[iconName]!
        : _materialIcons[iconName] ?? _cupertinoIcons[iconName]!;
  }
}
