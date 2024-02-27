# Use the official Python 3.9 image based on Alpine Linux version 3.13
FROM python:3.9-alpine3.13

# Set the maintainer information for the Docker image
LABEL maintainer="Horace"

# Set environment variables
ENV PYTHONUNBUFFERED=1
ARG DEV=false

# Create a non-root user for increased security
RUN adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Set the working directory to /app in the Docker image
WORKDIR /app

# Copy only the necessary files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# Install system dependencies and clean up
RUN apk add --update --no-cache \
        postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    # Create a Python virtual environment named 'py' in the /py directory
    python -m venv /py && \
    # Upgrade pip and install project dependencies from requirements.txt
    /py/bin/pip install --upgrade pip -r /tmp/requirements.txt && \
    # Install additional development dependencies if in DEV mode
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt ;\
    fi && \
    # Remove temporary files and dependencies
    rm -rf /tmp && \
    apk del .tmp-build-deps

# Add the /py/bin directory to the system's PATH environment variable
ENV PATH="/py/bin:$PATH"

# Expose port 8080 to allow external connections
EXPOSE 8000

# Set the user to 'django-user' for increased security
USER django-user
