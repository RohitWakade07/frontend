library default_connector;

import 'package:firebase_data_connect/firebase_data_connect.dart';

class DefaultConnector {
  static ConnectorConfig connectorConfig = ConnectorConfig(
    'asia-east1',
    'default',
    'ridewise',
  );

  DefaultConnector({required this.dataConnect});

  static DefaultConnector get instance {
    return DefaultConnector(
      dataConnect: FirebaseDataConnect.instanceFor(
        connectorConfig: connectorConfig,
        // Remove the 'sdkType' parameter
      ),
    );
  }

  FirebaseDataConnect dataConnect;
}