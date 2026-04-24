import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class SettingsState {
  final bool isDarkMode;
  final bool isLocationSaved;
  final bool isNotificationsEnabled;

  SettingsState({
    this.isDarkMode = false,
    this.isLocationSaved = false,
    this.isNotificationsEnabled = false,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? isLocationSaved,
    bool? isNotificationsEnabled,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLocationSaved: isLocationSaved ?? this.isLocationSaved,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  late SharedPreferences _prefs;

  @override
  Future<SettingsState> build() async {
    _prefs = await SharedPreferences.getInstance();
    
    final isDark = _prefs.getBool('isDarkMode') ?? false;
    final isLoc = _prefs.getBool('isLocationSaved') ?? false;
    final isNotif = _prefs.getBool('isNotificationsEnabled') ?? false;
    
    return SettingsState(
      isDarkMode: isDark,
      isLocationSaved: isLoc,
      isNotificationsEnabled: isNotif,
    );
  }

  Future<void> toggleDarkMode(bool isDark) async {
    state = const AsyncLoading();
    await _prefs.setBool('isDarkMode', isDark);
    state = AsyncData(state.value!.copyWith(isDarkMode: isDark));
  }

  Future<void> toggleLocation(bool enable) async {
    state = const AsyncLoading();
    final user = FirebaseAuth.instance.currentUser;

    if (enable) {
      var status = await Permission.location.request();
      if (status.isGranted) {
        try {
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            // Provide a fallback if subLocality is null
            final address = "${place.subLocality?.isNotEmpty == true ? place.subLocality : place.locality}, ${place.administrativeArea}";
            
            if (user != null) {
              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                'savedLocation': address,
              });
            }
          }
          await _prefs.setBool('isLocationSaved', true);
          state = AsyncData(state.value!.copyWith(isLocationSaved: true));
        } catch (e) {
          print('Error getting location: $e');
          state = AsyncData(state.value!.copyWith(isLocationSaved: false));
        }
      } else {
        state = AsyncData(state.value!.copyWith(isLocationSaved: false));
      }
    } else {
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'savedLocation': FieldValue.delete(),
        });
      }
      await _prefs.setBool('isLocationSaved', false);
      state = AsyncData(state.value!.copyWith(isLocationSaved: false));
    }
  }

  Future<void> toggleNotifications(bool enable) async {
    state = const AsyncLoading();
    final user = FirebaseAuth.instance.currentUser;

    if (enable) {
      var status = await Permission.notification.request();
      if (status.isGranted) {
        try {
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (user != null && fcmToken != null) {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              'fcmToken': fcmToken,
            });
          }
          await _prefs.setBool('isNotificationsEnabled', true);
          state = AsyncData(state.value!.copyWith(isNotificationsEnabled: true));
        } catch (e) {
          print('Error enabling notifications: $e');
          state = AsyncData(state.value!.copyWith(isNotificationsEnabled: false));
        }
      } else {
        state = AsyncData(state.value!.copyWith(isNotificationsEnabled: false));
      }
    } else {
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
        });
      }
      await FirebaseMessaging.instance.deleteToken();
      await _prefs.setBool('isNotificationsEnabled', false);
      state = AsyncData(state.value!.copyWith(isNotificationsEnabled: false));
    }
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
