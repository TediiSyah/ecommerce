import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind('localhost', 3000);
  print('Proxy server running on http://localhost:3000');

  await for (HttpRequest request in server) {
    try {
      // Handle preflight OPTIONS request
      if (request.method == 'OPTIONS') {
        _handleOptions(request);
        continue;
      }

      // Forward the request to the actual API server
      final client = HttpClient();
      final uri = request.uri.replace(
        scheme: 'http',
        host: 'localhost',
        port: 8000,
      );

      final proxyRequest = await client.openUrl(request.method, uri);
      
      // Copy headers
      request.headers.forEach((name, values) {
        if (name != 'host' && name != 'origin' && name != 'referer') {
          proxyRequest.headers.set(name, values.join(','));
        }
      });

      // Set CORS headers
      proxyRequest.headers.set('Access-Control-Allow-Origin', '*');
      
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

void _handleOptions(HttpRequest request) {
  request.response.statusCode = HttpStatus.ok;
  request.response.headers.set('Access-Control-Allow-Origin', '*');
  request.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  request.response.headers.set('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization');
  request.response.close();
}
