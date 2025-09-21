import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: '카카오_네이티브앱키'); //나중에 추가
  runApp(const ProviderScope(child: TheReadyApp()));
}
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
