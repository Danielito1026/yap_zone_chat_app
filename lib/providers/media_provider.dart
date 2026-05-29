import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/services/media_service.dart';

final mediaServiceProvider = Provider<MediaService>((ref) => MediaService());