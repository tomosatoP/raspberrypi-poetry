# コンテナ内で python 仮想環境 poetry を使う 

https://python-poetry.org/docs/

python 仮想環境 poetry を docker image に固めて、使い回す。
- target : Raspberry Pi OS 64-bit (bookworm)

参考にした書籍 : "動かして学ぶ！Python FastAPI 開発入門" ISBN978-4-7981-7771-7


## 固めた python 仮想環境 poetry のイメージの使い方

### my_project コンテナの作成

~~~sh
mkdir .dockervenv
docker compose build --pull --no-cache
~~~

フォルダ構成の例 (src レイアウト) 
~~~sh
my_project/ ────────── README.md
  │                    Dockerfile
  │                    compose.yaml
  │                    pyproject.toml
  ├─ .dockervenv/ ──── (省略)
  └─ src/my_package ── main.py
           ├─ libs/ ── 
~~~

Dockerfile の例
~~~Dockerfile
FROM tomosatop/poetry

COPY pyproject.toml* poetry.lock* ./
RUN if [ -f pyproject.toml ]; then poetry install --no-root; fi

ENTRYPOINT ["poetry", "run"]
CMD ["python", "main.py"]
~~~

compose.yaml の例
~~~yaml
services:
  application:
    build: .
    init: true
    ports:
      - 8000:8000
    working_dir: /application
    volumes:
      - .:/application
      - .dockervenv:/application/.venv
    command: python main.py
    environment:
      WATCHFILES_FORCE_POLLING: true
      TZ: Asia/Tokyo
    restart: always
~~~

### 仮想環境の初期化

対話的に `pyproject.toml` を作成、***既に作成済みなら不要***
~~~sh
docker compose run --entrypoint "poetry init --name my_package" application
~~~

### 仮想環境に依存パッケージをインストール

~~~sh
# pyproject.toml に登録
docker compose run --entrypoint "poetry add package1 package2" application
# poetry.lock を作成、もしくは更新
docker compose run --entrypoint "poetry update --lock --only main" application
# poetry.lock, pyprojetct.toml の内容を反映
docker compose run --entrypoint "poetry install --no-root --only main" application
~~~
> `my_package` もパッケージ化する場合、オプション `--no-root` を削除

## 開発目的の依存パッケージを追加インストール

例えば、 python リンター・フォーマッターの ruff の場合:
~~~sh
docker compose run --entrypoint "poetry add ruff --group dev" application
docker compose run --entrypoint "poetry update --lock --with dev" application
docker compose run --entrypoint "poetry install --no-root --with dev" application
~~~

例えば、ドキュメント作成ツール sphinx の場合:

~~~sh
docker compose run --entrypoint "poetry add Sphinx sphinx-rtd-theme --group docs" application
docker compose run --entrypoint "poetry update --lock --with docs" application
docker compose run --entrypoint "poetry install --no-root --with docs" application
~~~

例えば、テストツール pytest の場合:

~~~sh
docker compose run --entrypoint "poetry add pytest coverrage --group test" application
docker compose run --entrypoint "poetry update --lock --with test" application
docker compose run --entrypoint "poetry install --no-root --with test" application
~~~

---

## Build & push poetry-image

~~~sh
docker build --push -t tomosatop/poetry .
~~~
