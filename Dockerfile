# Use the official lightweight Python image.
FROM python:3.9-slim

ARG PORT=8080

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy requirements and install before copying code for faster builds
COPY requirements.txt requirements.txt

# install requirements
RUN pip install -r requirements.txt

# Copy local code to the container image.
COPY src src
COPY main.py main.py

# Expose port
EXPOSE $PORT

# run server
CMD exec gunicorn main:app --bind :8080 --log-level error --workers 8 --timeout 0
