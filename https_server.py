import http.server
import ssl
import os

PORT = 8443

cert_path = os.path.abspath("sacmi.crt")
key_path = os.path.abspath("sacmi.key")

httpd = http.server.HTTPServer(('0.0.0.0', PORT), http.server.SimpleHTTPRequestHandler)

context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(certfile=cert_path, keyfile=key_path)

httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

print(f"Server HTTPS attivo su https://localhost:{PORT}")
httpd.serve_forever()
