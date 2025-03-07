#!/bin/bash
# WordPress Docker Environment Setup Script

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}WordPress Docker Environment Setup${NC}"
echo "This script will set up the development environment for WordPress"

# Check if .env file exists, create from example if not
if [ ! -f .env ] && [ -f .env.example ]; then
  echo -e "${BLUE}Creating .env file from .env.example...${NC}"
  cp .env.example .env
  
  # Auto-detect current user's UID and GID
  sed -i "s/UID=1000/UID=$(id -u)/" .env
  sed -i "s/GID=1000/GID=$(id -g)/" .env
  
  echo -e "${GREEN}.env file created with your user permissions.${NC}"
fi

# Ensure themes directory exists with correct permissions
if [ ! -d "themes" ]; then
  echo -e "${BLUE}Creating themes directory...${NC}"
  mkdir -p themes
fi

# Ensure themes directory has correct permissions
echo -e "${BLUE}Setting correct permissions for themes directory...${NC}"
chmod -R 777 themes

# Prompt user about starting Docker containers
read -p "Would you like to start the WordPress environment now? (y/n): " START_ENV
if [ "$START_ENV" = "y" ] || [ "$START_ENV" = "Y" ]; then
  echo -e "${BLUE}Starting Docker containers...${NC}"
  docker-compose down
  docker-compose up -d
  
  echo -e "${GREEN}Environment is now running!${NC}"
  
  # Show endpoints
  source .env
  WP_PORT=${WP_PORT:-80}
  PMA_PORT=${PMA_PORT:-8080}
  
  echo -e "\n${BLUE}Access your services:${NC}"
  echo -e "WordPress: ${GREEN}http://localhost:$WP_PORT${NC}"
  echo -e "PhpMyAdmin: ${GREEN}http://localhost:$PMA_PORT${NC}"
  echo -e "Next.js Frontend: ${GREEN}http://localhost:3000${NC}"
else
  echo -e "${BLUE}You can start the environment later with:${NC} docker-compose up -d"
fi

echo -e "\n${GREEN}Setup completed successfully!${NC}"
echo -e "You can create a steampunk theme with: ${BLUE}./create-steampunk-theme.sh${NC}"
echo -e "You can create a Next.js frontend with: ${BLUE}./create-nextjs-frontend.sh${NC}"