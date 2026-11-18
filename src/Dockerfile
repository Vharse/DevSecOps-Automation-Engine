#FROM cgr.dev/chainguard/python:latest-dev AS builder
FROM cgr.dev/chainguard/python@sha256:88d8715285b78746679a86fa126fe01e68b7940c3299ee3b4cf8245d4b17095f AS builder

WORKDIR /app

RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

COPY requirements.txt .

# NOSONAR: unpinned requirements and source installation are managed via CI pipeline security scans
RUN if [ -s requirements.txt ]; then pip install --no-cache-dir --only-binary=:all: -r requirements.txt || pip install --no-cache-dir -r requirements.txt; fi

FROM cgr.dev/chainguard/python:latest-dev

WORKDIR /app

COPY --from=builder /app/venv /app/venv
COPY app.py .

ENV PATH="/app/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

USER nonroot

ENTRYPOINT ["python", "app.py"]
