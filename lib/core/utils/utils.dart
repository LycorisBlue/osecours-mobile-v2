// lib/utils/utils.dart
import 'package:geocoding/geocoding.dart';

class Utils {
  // Formatage du temps écoulé
  static String timeAgo(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return "À l'instant";
      } else if (difference.inMinutes < 60) {
        return "Il y a ${difference.inMinutes} min";
      } else if (difference.inHours < 24) {
        return "Il y a ${difference.inHours}h";
      } else {
        int days = difference.inDays;

        if (days == 1) {
          return "Il y a 1 jour";
        } else if (days < 7) {
          return "Il y a $days jours";
        } else {
          int weeks = (days / 7).floor();
          if (weeks == 1) {
            return "Il y a 1 semaine";
          } else if (weeks < 4) {
            return "Il y a $weeks semaines";
          } else {
            int months = (days / 30).floor();
            if (months == 1) {
              return "Il y a 1 mois";
            } else if (months < 12) {
              return "Il y a $months mois";
            } else {
              int years = (days / 365).floor();
              if (years == 1) {
                return "Il y a 1 an";
              } else {
                return "Il y a $years ans";
              }
            }
          }
        }
      }
    } catch (e) {
      return dateString; // En cas d'erreur, retourne la chaîne d'origine
    }
  }

  // Conversion des coordonnées en adresse
  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // On prend uniquement la localité et la sous-localité si disponible
        String address = place.locality ?? '';
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += place.subLocality!.isNotEmpty ? ', ${place.subLocality}' : '';
        }
        return address.isNotEmpty ? address : 'Adresse inconnue';
      }
      return 'Adresse inconnue';
    } catch (e) {
      return 'Adresse inconnue';
    }
  }
}
