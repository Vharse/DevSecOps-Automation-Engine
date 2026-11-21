FROM cgr.dev/chainguard/python@sha256:f6e5c2e056393d48fa8afa1ea58a1394db4cd5de1a8f0f48105c8e88fcd4f9d3 AS builder

WORKDIR /app

RUN ["python", "-m", "venv", "/app/venv"]
ENV PATH="/app/venv/bin:$PATH"

COPY requirements.txt .

# NOSONAR: unpinned requirements and source installation are managed via CI pipeline security scans
RUN if [ -s requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

FROM cgr.dev/chainguard/python@sha256:f6e5c2e056393d48fa8afa1ea58a1394db4cd5de1a8f0f48105c8e88fcd4f9d3 AS runtime
WORKDIR /app

COPY --from=builder /app/venv /app/venv
COPY app.py .

ENV PATH="/app/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

USER nonroot

ENTRYPOINT ["python", "app.py"]
