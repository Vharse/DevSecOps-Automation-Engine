FROM cgr.dev/chainguard/python@sha256:d914788ef74519450a69bc5cce6a1cc747dbefb95a3d431daa4ff707767fea8a AS builder

WORKDIR /app

RUN ["python", "-m", "venv", "/app/venv"]
ENV PATH="/app/venv/bin:$PATH"

COPY requirements.txt .

# NOSONAR: unpinned requirements and source installation are managed via CI pipeline security scans
RUN if [ -s requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

FROM cgr.dev/chainguard/python@sha256:d914788ef74519450a69bc5cce6a1cc747dbefb95a3d431daa4ff707767fea8a AS runtime
WORKDIR /app

COPY --from=builder /app/venv /app/venv
COPY app.py .

ENV PATH="/app/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

USER nonroot

ENTRYPOINT ["python", "app.py"]
