"""Serves build/web locally for testing: python serve.py [port]

Python's built-in `python -m http.server` keeps a queue of only 5 waiting connections, and a
Flutter page requests dozens of files at once (fonts, icons, images), so on Windows some
requests are refused and assets fail to load. This server queues plenty and serves each request
on its own thread.
"""
import functools
import http.server
import sys
from pathlib import Path

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8091
ROOT = Path(__file__).parent / "build" / "web"


class Server(http.server.ThreadingHTTPServer):
    request_queue_size = 256
    daemon_threads = True


class Handler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {**http.server.SimpleHTTPRequestHandler.extensions_map, ".wasm": "application/wasm", ".webp": "image/webp"}

    def log_message(self, *args):  # keep the console quiet
        pass


if __name__ == "__main__":
    with Server(("", PORT), functools.partial(Handler, directory=str(ROOT))) as httpd:
        print(f"Serving {ROOT} at http://localhost:{PORT}")
        httpd.serve_forever()
