# Start with a full Python image that already has pip and build tools
FROM python:3.11-bookworm

# Install LibreOffice and fonts
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libreoffice-writer \
        libreoffice-core \
        libreoffice-common \
        fonts-dejavu-core \
        curl \
        ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Workdir
WORKDIR /app

# Copy requirements and install Python packages
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Flask service
COPY server.py /app/

EXPOSE 8080
CMD ["python", "server.py"]