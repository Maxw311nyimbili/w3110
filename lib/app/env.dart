import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'API_URL_DEV', obfuscate: true)
  static final String apiUrlDev = _Env.apiUrlDev;

  @EnviedField(varName: 'API_URL_STAGING', obfuscate: true)
  static final String apiUrlStaging = _Env.apiUrlStaging;

  @EnviedField(varName: 'API_URL_PROD', obfuscate: true)
  static final String apiUrlProd = _Env.apiUrlProd;
}
