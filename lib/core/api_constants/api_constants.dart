class ApiConstants {
  static String baseUrl = '';

  /*final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration.zero,
      ),
    );

    await remoteConfig.setDefaults({'baseUrl': 'no url'});

    try {
      await remoteConfig.fetch();
      await remoteConfig.activate();
    } catch (e) {
      baseUrl = 'https://zetahrms-saas.com/AiaslBackend/api';
      print('Error fetching remote config: $e');
    }
    print("baseUrl");
    baseUrl = remoteConfig.getString('baseUrl').trim();
    print(baseUrl);

    print('Fetched baseUrl: $baseUrl');
  }*/
}
