FROM python:3.12.2-bookworm

WORKDIR /application
EXPOSE 8000

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

ENV PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/usr/local/bin \
    PIPX_MAN_DIR=/usr/local/share/man

ENV POETRY_VIRTUALENVS_IN_PROJECT=true

RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
    pipx \
    && apt-get clean \
    && rm  -rf /var/lib/apt/lists/*

RUN pipx install poetry

CMD ["python"]
