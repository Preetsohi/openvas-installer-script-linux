#!/bin/bash

set -e

echo "============================="
echo "   OpenVAS Installer v2.0"
echo "============================="

CONTAINER_NAME="openvas"
IMAGE_NAME="immauss/openvas:latest"
PORT="8080"
PASSWORD="StrongPass123"

echo ""
echo "### [1] Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Install Docker first!"
    exit 1
else
    echo "✔ Docker is installed."
fi

echo ""
echo "### [2] Checking Docker service status..."
if ! systemctl is-active --quiet docker; then
    echo "❌ Docker service is not running. Starting now..."
    sudo systemctl start docker
fi
echo "✔ Docker service running."

echo ""
echo "### [3] Checking for existing OpenVAS container..."
if sudo docker ps -a --format '{{.Names}}' | grep -w "$CONTAINER_NAME" >/dev/null; then
    echo "⚠ Found existing container: $CONTAINER_NAME"
    echo "   → Stopping and removing..."
    sudo docker rm -f "$CONTAINER_NAME"
    sleep 2
fi
echo "✔ No conflicting container."

echo ""
echo "### [4] Cleaning old volumes & data traces..."
sudo docker volume prune -f || true
sudo rm -rf /opt/openvas-data || true
echo "✔ Cleaned old data."

echo ""
echo "### [5] Pulling latest OpenVAS Docker image..."
sudo docker pull $IMAGE_NAME
echo "✔ Image pulled successfully."

echo ""
echo "### [6] Running fresh OpenVAS container (no volumes)..."
sudo docker run -d \
    --name $CONTAINER_NAME \
    --privileged \
    --shm-size=4g \
    -p $PORT:9392 \
    -e PASSWORD="$PASSWORD" \
    $IMAGE_NAME

echo "✔ Container created."

echo ""
echo "### [7] Validating container startup..."
sleep 8

STATUS=$(sudo docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME")

if [ "$STATUS" != "running" ]; then
    echo "❌ Container not running properly!"
    echo "### Dumping logs for diagnosis ###"
    sudo docker logs "$CONTAINER_NAME"
    echo ""
    echo "❌ Installation failed."
    exit 1
else
    echo "✔ Container is running."
fi

echo ""
echo "### [8] Checking for critical errors in logs..."
LOG_OUTPUT=$(sudo docker logs "$CONTAINER_NAME" 2>&1)

if echo "$LOG_OUTPUT" | grep -q "postgresql.conf"; then
    echo "❌ ERROR: PostgreSQL failed to initialize!"
    echo "   This indicates broken data folders or volume issues."
    sudo docker logs "$CONTAINER_NAME"
    exit 1
fi

if echo "$LOG_OUTPUT" | grep -q "redis"; then
    echo "✔ Redis OK (initial warnings normal)."
fi

if echo "$LOG_OUTPUT" | grep -q "Starting gvmd"; then
    echo "✔ GVMD initialization sequence found."
else
    echo "⚠ GVMD may still be starting..."
fi

echo ""
echo "### [9] Setting container to auto-start on reboot..."
sudo docker update --restart unless-stopped $CONTAINER_NAME
echo "✔ Auto-start enabled."

echo ""
echo "=============================="
echo "   OpenVAS Installation Done"
echo "=============================="
echo ""
echo "Login URL : http://localhost:$PORT"
echo "Username  : admin"
echo "Password  : $PASSWORD"
echo ""
echo "Use this to view logs:"
echo "   sudo docker logs -f openvas"
echo ""
echo "If login fails, run:"
echo "   sudo docker restart openvas"
echo ""
