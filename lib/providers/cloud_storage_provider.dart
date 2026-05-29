import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/services/cloud_storage_service.dart';

final cloudStorageServiceProvider = Provider<CloudStorageService>((ref) => CloudStorageService());