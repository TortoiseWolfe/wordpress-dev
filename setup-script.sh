#!/bin/bash
# Setup script for WordPress development environment

# Create .env with current user's UID and GID
cp .env.example .env
sed -i "s/UID=1000/UID=$(id -u)/" .env
sed -i "s/GID=1000/GID=$(id -g)/" .env

# Create themes directory if it doesn't exist
mkdir -p themes

# Make sure permissions are correct
chmod 755 themes

# Start containers
docker compose up -d

echo "WordPress development environment is now running!"
echo "WordPress: http://localhost:8000"
echo "phpMyAdmin: http://localhost:8080"
