class CurlParser {
  static final RegExp _headerRegex = RegExp(
    r"(-H|--header)\s+['"
            '"'
            r"]?([^'"
            '"'
            r"]+)['" +
        '"' +
        r"]?",
  );
  static final RegExp _methodRegex = RegExp(r"(-X|--request)\s+([A-Z]+)");
  static final RegExp _dataRegex = RegExp(
    r"(-d|--data|--data-raw)\s+['"
    '"'
    r"]?(.*?)['"
    '"'
    r"]?(\s|$)",
    multiLine: true,
    dotAll: true,
  );
  static final RegExp _urlRegex = RegExp(
    r"['"
            '"'
            r"]?(https?://[^'"
            '"'
            r"\s]+)['" +
        '"' +
        r"]?",
  );

  static ParsedCurl? parse(String curlCommand) {
    if (!curlCommand.trim().toLowerCase().startsWith('curl')) return null;

    String method = 'GET';
    String url = '';
    Map<String, String> headers = {};
    String? body;

    // Extract Method
    final methodMatch = _methodRegex.firstMatch(curlCommand);
    if (methodMatch != null) {
      method = methodMatch.group(2) ?? 'GET';
    }

    // Extract URL
    // We remove the curl, method, headers, etc to find the potential URL
    // Or just regex find http/https
    final urlMatch = _urlRegex.firstMatch(curlCommand);
    if (urlMatch != null) {
      url = urlMatch.group(1) ?? '';
    }

    // Extract Headers
    final headerMatches = _headerRegex.allMatches(curlCommand);
    for (final match in headerMatches) {
      final headerStr = match.group(2);
      if (headerStr != null) {
        final parts = headerStr.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join(':').trim();
          headers[key] = value;
        }
      }
    }

    // Extract Body
    // Handling multiline bodies is tricky with simple regex if they span lines without quotes properly
    // But let's try a best effort
    final dataMatch = _dataRegex.firstMatch(curlCommand);
    if (dataMatch != null) {
      body = dataMatch.group(2);
      // Determine method if implied (POST if body present and no method specified)
      if (method == 'GET') {
        method = 'POST';
      }
    }

    return ParsedCurl(method: method, url: url, headers: headers, body: body);
  }
}

class ParsedCurl {
  final String method;
  final String url;
  final Map<String, String> headers;
  final String? body;

  ParsedCurl({
    required this.method,
    required this.url,
    required this.headers,
    this.body,
  });
}
