# Stage 1: Build Stage
# Use a Python image for building the application
FROM python:3.9-slim AS build

# Set the working directory
WORKDIR /app

# Copy application code into the container
COPY . /app

# Install dependencies in the build stage
RUN pip install -r requirements.txt

# Stage 2: Final Stage
# Use a lightweight Python image for the runtime environment
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the dependencies from the build stage
COPY --from=build /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

# Copy the application code
COPY --from=build /app /app

# Expose the port the app will run on
EXPOSE 80

# Command to run the app
CMD ["python", "app.py"]
