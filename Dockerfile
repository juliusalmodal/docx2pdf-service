# Use a full Debian base instead of slim
FROM debian:bookworm-slim

# Install dependencies and LibreOffice
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libreoffice-writer \
        libreoffice-core \
        libreoffice-common \
        fonts-dejavu-core \
        python3 \
        python3-pip \
        curl \
        ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Copy Python files
COPY requirements.txt /app/
RUN pip3 install --no-cache-dir -r requirements.txt

COPY server.py /app/

EXPOSE 8080
CMD ["python3", "server.py"]