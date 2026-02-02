import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class OAuth2Service {
  final Dio _dio = Dio();

  Future<String> getAccessToken({
    required String tokenUrl,
    required String clientId,
    required String clientSecret,
    String? grantType,
    String? username,
    String? password,
    String? scope,
    String? code,
    String? redirectUri,
  }) async {
    final Map<String, dynamic> data = {
      'grant_type': grantType ?? 'client_credentials',
      'client_id': clientId,
      'client_secret': clientSecret,
    };

    if (scope != null && scope.isNotEmpty) {
      data['scope'] = scope;
    }

    if (grantType == 'password') {
      data['username'] = username;
      data['password'] = password;
    } else if (grantType == 'authorization_code') {
      data['code'] = code;
      data['redirect_uri'] = redirectUri;
    }

    try {
      final response = await _dio.post(
        tokenUrl,
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        final body = response.data;
        return body['access_token'] ?? '';
      } else {
        throw Exception('Failed to get access token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching OAuth2 token: $e');
    }
  }

  /// Flow for Authorization Code
  Future<String> authorizeAndGetToken({
    required String authUrl,
    required String tokenUrl,
    required String clientId,
    required String clientSecret,
    required String scope,
  }) async {
    const port = 54321;
    final redirectUri = 'http://localhost:$port';

    // 1. Start local server
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);

    try {
      // 2. Build Auth URL
      final uri = Uri.parse(authUrl).replace(
        queryParameters: {
          'response_type': 'code',
          'client_id': clientId,
          'redirect_uri': redirectUri,
          'scope': scope,
        },
      );

      // 3. Launch browser
      if (!await launchUrl(uri)) {
        throw Exception('Could not launch $uri');
      }

      // 4. Wait for code
      String? authCode;
      await for (var request in server) {
        final params = request.uri.queryParameters;
        authCode = params['code'];

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.html
          ..write(
            '<h1>Autenticación exitosa</h1><p>Puedes cerrar esta ventana y volver a Xolo.</p>',
          )
          ..close();

        if (authCode != null) break;
      }

      if (authCode == null) throw Exception('Authorization code not found');

      // 5. Exchange code for token
      return await getAccessToken(
        tokenUrl: tokenUrl,
        clientId: clientId,
        clientSecret: clientSecret,
        grantType: 'authorization_code',
        code: authCode,
        redirectUri: redirectUri,
      );
    } finally {
      await server.close();
    }
  }
}

final oauth2ServiceProvider = Provider<OAuth2Service>((ref) => OAuth2Service());
