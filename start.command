#!/bin/bash
cd "$(dirname "$0")"
PORT=8877
# Stop only an older WOOLLY server on the same port, if one exists.
lsof -ti tcp:$PORT | xargs kill -9 2>/dev/null || true
python3 - "$PORT" <<'PY' &
import http.server, socketserver, sys
PORT=int(sys.argv[1])
class NoCache(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control','no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma','no-cache')
        self.send_header('Expires','0')
        super().end_headers()
with socketserver.TCPServer(('127.0.0.1',PORT),NoCache) as httpd:
    httpd.serve_forever()
PY
SERVER_PID=$!
sleep 1
open "http://127.0.0.1:$PORT/index.html?v=20261005-1735"
echo "WOOLLY 최신 빌드를 실행했습니다: http://127.0.0.1:$PORT/index.html?v=20261005-1735"
echo "이 창을 닫으면 로컬 서버도 종료됩니다."
trap 'kill $SERVER_PID 2>/dev/null' EXIT
wait $SERVER_PID
