import 'app_config.dart';
import 'env_url.dart';

void setTechnicianConfig({AppEnvironment env = AppEnvironment.live}) {
  AppConfig.instance = AppConfig(
    environment: env,
    appName: 'Hammer Technician',
    baseUrl: env == AppEnvironment.dev
        ? EnvUrls.devBaseUrl
        : EnvUrls.liveBaseUrl,
  );
}
