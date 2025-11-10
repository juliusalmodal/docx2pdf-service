# Use Debian slim base for stable LibreOffice install
FROM debian:bookworm-slim

# Install system packages and LibreOffice
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libreoffice-writer \
        libreoffice-core \
        libreoffice-common \
        fonts-dejavu-core \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        python3-dev \
        curl \
        ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt /app/
RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir -r requirements.txt

# Copy the app
COPY server.py /app/

EXPOSE 8080
CMD ["python3", "server.py"]