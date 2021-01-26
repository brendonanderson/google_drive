import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:google_drive/domain/secret.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class ClientService {
  static AutoRefreshingAuthClient _client;
  final ClientId _clientId = new ClientId(Secret.ANDROID_CLIENT_ID, '');
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<AutoRefreshingAuthClient> getClient(List<String> scopes) async {
    if (_client == null && (await _storage.read(key: 'refreshToken')) == null) {
      _client = await _authenticate(scopes);
      _storage.write(
          key: 'accessToken', value: _client.credentials.accessToken.data);
      _storage.write(key: 'type', value: _client.credentials.accessToken.type);
      _storage.write(
          key: 'expiry',
          value: _client.credentials.accessToken.expiry.toString());
      _storage.write(
          key: 'refreshToken', value: _client.credentials.refreshToken);
    } else if (_client == null) {
      _client = await _authWithRefreshToken(scopes);
    }
    return _client;
  }

  Future<AutoRefreshingAuthClient> _authenticate(List<String> scopes) async {
    final url = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'response_type': 'code',
      'client_id': Secret.ANDROID_CLIENT_ID,
      'redirect_uri': '${Secret.REDIRECT_URI}:/',
      'scope': scopes.join(' ')
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(), callbackUrlScheme: Secret.REDIRECT_URI);

    final code = Uri.parse(result).queryParameters['code'];

    final response =
        await http.post('https://www.googleapis.com/oauth2/v4/token', body: {
      'client_id': Secret.ANDROID_CLIENT_ID,
      'redirect_uri': '${Secret.REDIRECT_URI}:/',
      'grant_type': 'authorization_code',
      'code': code
    });
    Map m = jsonDecode(response.body);
    final accessToken = m['access_token'] as String;
    final refreshToken = m['refresh_token'] as String;
    final expiry = m['expires_in'] as int;
    final scope = m['scope'] as String; //not used in this case
    final type = m['token_type'] as String;

    DateTime expiresAt =
        DateTime.now().toUtc().add(Duration(seconds: expiry - 1));

    AccessToken token = AccessToken(type, accessToken, expiresAt);
    AccessCredentials creds = await refreshCredentials(_clientId,
        AccessCredentials(token, refreshToken, scopes), http.Client());
    http.Client c = http.Client();
    AuthClient authClient = autoRefreshingClient(_clientId, creds, c);
    return authClient;
  }

  Future<AutoRefreshingAuthClient> _authWithRefreshToken(
      List<String> scopes) async {
    String data = await _storage.read(key: 'accessToken');
    String type = await _storage.read(key: 'type');
    String expiry = await _storage.read(key: 'expiry');
    String refreshToken = await _storage.read(key: 'refreshToken');
    AccessToken accessToken =
        AccessToken(type, data, DateTime.tryParse(expiry));
    AccessCredentials creds = await refreshCredentials(_clientId,
        AccessCredentials(accessToken, refreshToken, scopes), http.Client());
    http.Client c = http.Client();
    AuthClient authClient = autoRefreshingClient(_clientId, creds, c);
    return authClient;
  }
}
