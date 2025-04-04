# Django Server

This is a Django web application project.

## Environment Setup

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Update the `.env` file with your specific configuration:
   - Generate a new `SECRET_KEY`
   - Set appropriate `DEBUG` value
   - Configure `ALLOWED_HOSTS`
   - Configure PostgreSQL connection details (required for development and production)
   - Set `ENABLE_SENTRY` to `True` if you want to use Sentry
   - Add your `SENTRY_DSN` (if using Sentry)

## Local Development Setup

1. Create a virtual environment:
   ```bash
   python3 -m venv venv
   ```

2. Activate the virtual environment:
   - On macOS/Linux:
     ```bash
     source venv/bin/activate
     ```
   - On Windows:
     ```bash
     .\venv\Scripts\activate
     ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Run migrations:
   ```bash
   python manage.py migrate
   ```

5. Start the development server:
   ```bash
   python manage.py runserver
   ```

The server will be available at http://127.0.0.1:8000/

## Docker Setup

### Using Docker Compose (Recommended)

The application uses a `start_server.sh` script that automatically:
- Waits for the database to be ready
- Applies database migrations
- Collects static files
- Starts the Gunicorn server

1. Build and start the containers:
   ```bash
   # For development
   docker-compose -f docker-compose.dev.yml up -d
   
   # For production
   docker-compose -f docker-compose.prod.yml up -d
   ```

2. Create a superuser (optional):
   ```bash
   docker-compose exec web python manage.py createsuperuser
   ```

3. View logs:
   ```bash
   docker-compose logs -f
   ```

4. Stop the containers:
   ```bash
   docker-compose down
   ```

### Using Docker Directly

1. Build the Docker image:
   ```bash
   docker build -t django-server .
   ```

2. Run the container:
   ```bash
   docker run -d -p 8000:8000 \
     --env-file .env \
     django-server
   ```

The server will be available at http://127.0.0.1:8000/

## Environment Variables

### Django Settings
- `DJANGO_ENV`: The environment the application is running in (default: "development")
- `DEBUG`: Enable debug mode (default: "False")
- `SECRET_KEY`: Django secret key for security
- `ALLOWED_HOSTS`: Comma-separated list of allowed hosts

### Database Settings
- `USE_POSTGRES`: Enable or disable PostgreSQL (default: "False")
- `DATABASE_URL`: Database connection URL (default: sqlite:///db.sqlite3)
- `POSTGRES_DB`: PostgreSQL database name (default: "django_db")
- `POSTGRES_USER`: PostgreSQL username (default: "django_user")
- `POSTGRES_PASSWORD`: PostgreSQL password (default: "django_password")
- `POSTGRES_HOST`: PostgreSQL host (default: "localhost")
- `POSTGRES_PORT`: PostgreSQL port (default: "5432")

### Sentry Configuration
- `ENABLE_SENTRY`: Enable or disable Sentry integration (default: "False")
- `SENTRY_DSN`: Your Sentry DSN for error tracking
- `SENTRY_TRACES_SAMPLE_RATE`: Sample rate for performance monitoring (default: 1.0)
- `SENTRY_PROFILES_SAMPLE_RATE`: Sample rate for profiling (default: 1.0)
- `SENTRY_ENVIRONMENT`: Environment name for Sentry (default: matches DJANGO_ENV)

### Server Settings
- `PORT`: Server port (default: 8000)
- `HOST`: Server host (default: 0.0.0.0)

## Project Structure

- `django_server/` - Main project configuration
- `manage.py` - Django's command-line utility for administrative tasks
- `Dockerfile` - Docker configuration for containerization
- `docker-compose.yml` - Docker Compose configuration
- `docker-compose.dev.yml` - Development-specific Docker Compose configuration
- `docker-compose.prod.yml` - Production-specific Docker Compose configuration
- `start_server.sh` - Server startup script (handles migrations and startup tasks)
- `requirements.txt` - Python dependencies
- `.env` - Environment variables (not in version control)
- `.env.example` - Example environment variables template

## Database Configuration

This project supports both SQLite and PostgreSQL databases:

### SQLite (Default for local development)
- No additional configuration needed
- Data is stored in a local file (`db.sqlite3`)

### PostgreSQL (Required for Docker environments)
To use PostgreSQL:

1. Configure PostgreSQL connection details in your `.env` file:
   - `POSTGRES_DB`: Database name
   - `POSTGRES_USER`: Username
   - `POSTGRES_PASSWORD`: Password
   - `POSTGRES_HOST`: Host (default: "localhost")
   - `POSTGRES_PORT`: Port (default: "5432")

2. For Docker environments (development and production), PostgreSQL is automatically enabled and will connect to the specified database.

## Error Tracking

This project uses Sentry for error tracking and performance monitoring. To enable Sentry:

1. Set `ENABLE_SENTRY=True` in your `.env` file
2. Sign up for a free account at [Sentry.io](https://sentry.io)
3. Create a new project and get your DSN
4. Add your DSN to the `.env` file
5. Sentry will automatically capture:
   - Unhandled exceptions
   - Performance metrics
   - User context (if enabled)
   - Environment information 