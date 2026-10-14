#!/usr/bin/env python3
import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

class NotifyHandler(BaseHTTPRequestHandler):
  def do_GET(self):
    parsed_url = urlparse(self.path)

    if parsed_url.path == '/favicon.ico':
      self.send_response(404)
      self.end_headers()
      return

    # Extract query parameters
    params = parse_qs(parsed_url.query)

    summary = params.get('summary', ['Alert'])[0]
    body = params.get('body', [''])[0]
    urgency = params.get('urgency', [None])[0]  # low, normal, or critical
    icon = params.get('icon', [None])[0]
    app_name = params.get('app_name', [None])[0]
    expire_time = params.get('expire_time', [None])[0]  # in milliseconds

    # Build notify-send command using a list to prevent shell injection
    cmd = ['notify-send']

    if urgency in ['low', 'normal', 'critical']:
      cmd.extend(['-u', urgency])

    if icon:
      cmd.extend(['-i', icon])

    if app_name:
      cmd.extend(['-a', app_name])

    if expire_time and expire_time.isdigit():
      cmd.extend(['-t', expire_time])

    cmd.append(summary)
    if body:
      cmd.append(body)

    try:
      subprocess.run(cmd, check=True)
      self.send_response(200)
      self.send_header('Content-Type', 'text/plain')
      self.end_headers()
      self.wfile.write(b'Notification sent successfully.\n')
    except subprocess.CalledProcessError as e:
      self.send_response(500)
      self.send_header('Content-Type', 'text/plain')
      self.end_headers()
      self.wfile.write(
          f'Failed to execute notify-send: {e}'.encode('utf-8')
      )


def run(host='0.0.0.0', port=14905):
  server_address = (host, port)
  httpd = HTTPServer(server_address, NotifyHandler)
  print(f'Server listening on http://{host}:{port}...')
  try:
    httpd.serve_forever()
  except KeyboardInterrupt:
    print('\nServer stopped.')


if __name__ == '__main__':
  run()
