# Use Python 3.11 slim as the base image
FROM python:3.11-slim as builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

# Final stage
FROM python:3.11-slim

# Create a non-root user
RUN useradd -m -u 1000 django

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV HOME=/home/django
ENV APP_HOME=/home/django/app
ENV DJANGO_ENV=production
ENV PORT=8000
ENV HOST=0.0.0.0

# Create necessary directories
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpq5 \
    netcat-traditional \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy wheels from builder and install
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache /wheels/*

# Copy project files
COPY . $APP_HOME

# Copy and set permissions for start script
COPY start_server.sh $APP_HOME/
RUN chmod +x $APP_HOME/start_server.sh

# Create directories for static and media files
RUN mkdir -p $APP_HOME/staticfiles $APP_HOME/media

# Change ownership of the app directory
RUN chown -R django:django $APP_HOME

# Switch to non-root user
USER django

# Expose port
EXPOSE $PORT

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$PORT/health/ || exit 1

# Start command
CMD ["./start_server.sh"] 