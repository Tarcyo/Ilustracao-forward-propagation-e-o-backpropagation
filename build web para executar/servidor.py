import argparse
import sys
import threading
import webbrowser
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit


PASTA_DO_APLICATIVO = Path(__file__).resolve().parent


class RequisicaoFlutter(SimpleHTTPRequestHandler):
    extensions_map = {
        **SimpleHTTPRequestHandler.extensions_map,
        ".html": "text/html; charset=utf-8",
        ".js": "text/javascript; charset=utf-8",
        ".mjs": "text/javascript; charset=utf-8",
        ".wasm": "application/wasm",
        ".json": "application/json",
        ".css": "text/css; charset=utf-8",
        ".woff": "font/woff",
        ".woff2": "font/woff2",
        ".ttf": "font/ttf",
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(PASTA_DO_APLICATIVO), **kwargs)

    def send_head(self):
        caminho = Path(self.translate_path(self.path))
        rota = urlsplit(self.path).path
        aceita_html = "text/html" in self.headers.get("Accept", "")
        recurso_do_build = rota.startswith(("/assets/", "/canvaskit/", "/icons/"))
        if (
            not caminho.exists()
            and not Path(rota).suffix
            and aceita_html
            and not recurso_do_build
        ):
            self.path = "/index.html"
        return super().send_head()

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


def main():
    argumentos = argparse.ArgumentParser(
        description="Serve o build web do Flutter na pasta deste arquivo."
    )
    argumentos.add_argument("--port", type=int, default=8000, help="Porta HTTP (8000).")
    argumentos.add_argument(
        "--no-browser", action="store_true", help="Não abrir o navegador automaticamente."
    )
    opcoes = argumentos.parse_args()

    if not 1 <= opcoes.port <= 65535:
        argumentos.error("A porta deve estar entre 1 e 65535.")

    if not (PASTA_DO_APLICATIVO / "index.html").is_file():
        print(
            "Não encontrei index.html. Coloque servidor.py dentro de build/web, "
            "ao lado do index.html gerado pelo Flutter.",
            file=sys.stderr,
        )
        return 1

    try:
        servidor = ThreadingHTTPServer(("127.0.0.1", opcoes.port), RequisicaoFlutter)
    except OSError as erro:
        print(
            f"Não foi possível iniciar na porta {opcoes.port}: {erro}\n"
            "Tente outra porta: py servidor.py --port 8080",
            file=sys.stderr,
        )
        return 1

    endereco = f"http://127.0.0.1:{opcoes.port}/"
    with servidor:
        print(f"Pasta: {PASTA_DO_APLICATIVO}")
        print(f"Aplicativo disponível em: {endereco}")
        print("Pressione Ctrl+C para encerrar.", flush=True)

        if not opcoes.no_browser:
            abertura = threading.Timer(0.5, webbrowser.open, args=(endereco,))
            abertura.daemon = True
            abertura.start()

        try:
            servidor.serve_forever()
        except KeyboardInterrupt:
            print("\nServidor encerrado.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
