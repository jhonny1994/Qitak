class AppRuntimeConfig {
  const AppRuntimeConfig._();

  static const String deepLinkBaseUrl = String.fromEnvironment(
    'APP_DEEP_LINK_BASE_URL',
  );
}
