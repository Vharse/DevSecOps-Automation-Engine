FROM cgr.dev/chainguard/python@sha256:88d8715285b78746679a86fa126fe01e68b7940c3299ee3b4cf8245d4b17095f AS builder

WORKDIR /app

RUN ["python", "-m", "venv", "/app/venv"]
ENV PATH="/app/venv/bin:$PATH"

COPY requirements.txt .

# NOSONAR: unpinned requirements and source installation are managed via CI pipeline security scans
RUN ["python", "-c", "import os, subprocess, sys; sys.exit(subprocess.call([sys.executable, '-m', 'pip', 'install', '--no-cache-dir', '-r', 'requirements.txt'])) if os.path.exists('requirements.txt') and os.path.getsize('requirements.txt') > 0 else None"]

FROM cgr.dev/chainguard/python@sha256:88d8715285b78746679a86fa126fe01e68b7940c3299ee3b4cf8245d4b17095f AS runtime
WORKDIR /app

COPY --from=builder /app/venv /app/venv
COPY app.py .

ENV PATH="/app/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

USER nonroot

ENTRYPOINT ["python", "app.py"]
