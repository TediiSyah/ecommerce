// This is a development proxy to handle CORS issues
// Only use this in development environment

import 'dart:io';

void main() async {
  final server = await HttpServer.bind('localhost', 8080);
  print('Proxy server running on http://localhost:8080');

  await for (HttpRequest request in server) {
    try {
      // Forward the request to the actual API server
      final client = HttpClient();
      final uri = request.uri.replace(
        scheme: 'http',
        host: 'localhost',
        port: 8000,
        path: 'api${request.uri.path}',
      );

      // Copy headers
      final headers = <String, String>{};
      request.headers.forEach((name, values) {
        if (name != 'host' && name != 'origin' && name != 'referer') {
          headers[name] = values.join(',');
        }
      });
      
      // Add CORS headers
      headers['Access-Control-Allow-Origin'] = '*';
      headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
      headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization';

      // Make the request to the actual API
      final proxyRequest = await client.openUrl(request.method, uri);
      headers.forEach((key, value) {
        proxyRequest.headers.set(key, value);
      });

      // Copy request body if present
      if (request.method != 'GET' && request.method != 'HEAD') {
        final bodyBytes = await request.fold<List<int>>(
          <int>[],
          (previous, element) => previous..addAll(element),
        );
        proxyRequest.add(bodyBytes);
      }

      // Get the response
      final response = await proxyRequest.close();
      
      // Set CORS headers on the response
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
      request.response.headers.set('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization');
      
      // Copy response status and headers
      request.response.statusCode = response.statusCode;
      response.headers.forEach((name, values) {
        if (name.toString().toLowerCase() != 'content-length') {
          request.response.headers.set(name, values.join(','));
        }
      });
      
      // Copy response body
      await response.pipe(request.response);
    } catch (e) {
      print('Proxy error: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write('Proxy error: $e');
      await request.response.close();
    }
  }
}
