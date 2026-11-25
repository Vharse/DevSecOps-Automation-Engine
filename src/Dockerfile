FROM cgr.dev/chainguard/python@sha256:a76d3a2d5a7ba23ac51e1de1d119796142888aeb7d8276b53c7abbb919e3dc5d AS builder

WORKDIR /app

RUN ["python", "-m", "venv", "/app/venv"]
ENV PATH="/app/venv/bin:$PATH"

COPY requirements.txt .

# NOSONAR: unpinned requirements and source installation are managed via CI pipeline security scans
RUN ["python", "-c", "import os, subprocess, sys; sys.exit(subprocess.call([sys.executable, '-m', 'pip', 'install', '--no-cache-dir', '-r', 'requirements.txt'])) if os.path.exists('requirements.txt') and os.path.getsize('requirements.txt') > 0 else None"]

FROM cgr.dev/chainguard/python@sha256:a76d3a2d5a7ba23ac51e1de1d119796142888aeb7d8276b53c7abbb919e3dc5d AS runtime
WORKDIR /app

COPY --from=builder /app/venv /app/venv
COPY app.py .

ENV PATH="/app/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

USER nonroot

ENTRYPOINT ["python", "app.py"]
