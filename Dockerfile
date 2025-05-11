# ─────────────── Dockerfile ───────────────
FROM python:3.12-slim

# Create non-root user
RUN adduser --disabled-password --gecos '' appuser
WORKDIR /app

# Copy requirements first for layer cache
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source
COPY app/ .

# Change ownership (but KEEP root for port 8000 bind)
RUN chown -R appuser /app

EXPOSE 8000
# NOTE: we stay root here; binding to 8000 is non-privileged
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
