# Use the official Python 3.9 image based on Alpine Linux version 3.13
FROM python:3.9-alpine3.13

# Set the maintainer information for the Docker image
LABEL maintainer="Horace Lwanda"

# Set an environment variable to ensure Python output is unbuffered
ENV PYTHONUNBUFFERED 1

# Copy only the necessary files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# Set the working directory to /app in the Docker image
WORKDIR /app

# Expose port 8080 to allow external connections
EXPOSE 8080

# Define a build argument for development mode, default to false
ARG DEV=false

# Create a Python virtual environment named 'py' in the /py directory,
# upgrade pip, install project dependencies from requirements.txt,
# remove the temporary requirements files, and create a non-root user named 'django-user'
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt ;\
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Add the /py/bin directory to the system's PATH environment variable
ENV PATH="/py/bin:$PATH"

# Set the user to 'django-user' for increased security
USER django-user
