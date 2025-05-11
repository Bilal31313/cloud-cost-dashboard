# Base image
FROM python:3.12-slim

# Create non-root user
RUN adduser --disabled-password --gecos '' appuser

# Set work directory
WORKDIR /app

# Copy only requirements first (for layer caching)
COPY app/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy entire app code
COPY app/ .

# Set permissions
RUN chown -R appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 80

# Start app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
