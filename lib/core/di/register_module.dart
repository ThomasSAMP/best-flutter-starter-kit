import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/navigation_observer.dart';
import '../config/env_config.dart';
import '../network/dio_client.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseStorage get storage => FirebaseStorage.instance;

  @lazySingleton
  Dio get dio => DioClient.createDio(
    baseUrl: EnvConfig.instance.apiUrl,
    enableLogging: EnvConfig.instance.enableLogging,
  );

  @lazySingleton
  AppNavigationObserver get navigationObserver => AppNavigationObserver();
}
