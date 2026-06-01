import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xolo/core/network/http_client_provider.dart';

class OAuth2Service {
  OAuth2Service(this._dio);

  final Dio _dio;

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
    String? codeVerifier,
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
      data['code_verifier'] = codeVerifier;
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
    final port = _randomPort();
    final redirectUri = 'http://localhost:$port';
    final state = _randomUrlSafeString(32);
    final codeVerifier = _randomUrlSafeString(64);
    final codeChallenge = _pkceS256(codeVerifier);

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
          'state': state,
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
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
        final callbackState = params['state'];

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.html
          ..write(
            '<h1>Autenticación exitosa</h1><p>Puedes cerrar esta ventana y volver a Xolo.</p>',
          );
        await request.response.close();

        if (callbackState != state) {
          throw Exception('Invalid OAuth state');
        }

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
        codeVerifier: codeVerifier,
      );
    } finally {
      await server.close();
    }
  }

  int _randomPort() {
    final random = Random.secure();
    return 49152 + random.nextInt(10000);
  }

  String _randomUrlSafeString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String _pkceS256(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}

final oauth2ServiceProvider = Provider<OAuth2Service>(
  (ref) => OAuth2Service(ref.read(dioProvider)),
);
