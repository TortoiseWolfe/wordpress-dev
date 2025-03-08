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
  USER_ID=$(id -u)
  GROUP_ID=$(id -g)
  sed -i "s/^UID=.*/USER_ID=$USER_ID/" .env
  sed -i "s/^GID=.*/GROUP_ID=$GROUP_ID/" .env
  
  echo -e "${GREEN}.env file created with your user permissions.${NC}"
fi

# Ensure required directories exist with correct permissions
if [ ! -d "themes" ]; then
  echo -e "${BLUE}Creating themes directory...${NC}"
  mkdir -p themes
fi

# Check if Next.js frontend exists
if [ -d "nextjs-frontend" ] && [ -f "nextjs-frontend/package.json" ]; then
  echo -e "${GREEN}Existing Next.js frontend found. Using it without changes.${NC}"
else
  echo -e "${BLUE}Next.js frontend not found. Creating minimal setup...${NC}"
  
  # Set SKIP_EXISTS_CHECK=0 to prevent automatic removal of existing directory
  # This allows the create-nextjs-frontend.sh script to prompt the user if directory exists
  export SKIP_EXISTS_CHECK=0
  ./create-nextjs-frontend.sh || {
    echo -e "${RED}Failed to create Next.js frontend. Please check the error and try again manually.${NC}"
    echo -e "${YELLOW}Continuing with setup, but Next.js and Storybook may not work properly.${NC}"
  }
fi

# Ensure themes directory has correct permissions
echo -e "${BLUE}Setting correct permissions for themes directory...${NC}"
chmod -R 777 themes

# Start Docker containers automatically
echo -e "${BLUE}Starting Docker containers...${NC}"
docker-compose down
docker-compose up -d

echo -e "${BLUE}Waiting for containers to initialize...${NC}"
sleep 5

# Verify container status
NEXTJS_STATUS=$(docker-compose ps nextjs | grep -c "Up" || echo "0")
STORYBOOK_STATUS=$(docker-compose ps storybook | grep -c "Up" || echo "0")

if [ "$NEXTJS_STATUS" -gt 0 ] && [ "$STORYBOOK_STATUS" -gt 0 ]; then
  echo -e "${GREEN}Next.js and Storybook containers are running.${NC}"
  echo -e "${YELLOW}Note: Storybook may take a few minutes to initialize on first run.${NC}"
else
  echo -e "${RED}Some containers may not have started properly. Check with 'docker-compose ps'.${NC}"
fi

echo -e "${GREEN}Environment is now running!${NC}"

# Show endpoints
source .env
WP_PORT=${WP_PORT:-80}
PMA_PORT=${PMA_PORT:-8080}
TRAEFIK_PORT=${TRAEFIK_PORT:-8000}

echo -e "\n${BLUE}Access your services:${NC}"
echo -e "WordPress: ${GREEN}http://localhost:$WP_PORT${NC} or ${GREEN}http://wp.localhost:$TRAEFIK_PORT${NC}"
echo -e "PhpMyAdmin: ${GREEN}http://localhost:$PMA_PORT${NC} or ${GREEN}http://pma.localhost:$TRAEFIK_PORT${NC}"
echo -e "Next.js Frontend: ${GREEN}http://localhost:3000${NC} or ${GREEN}http://next.localhost:$TRAEFIK_PORT${NC}"
echo -e "Storybook: ${GREEN}http://localhost:6007${NC} or ${GREEN}http://storybook.localhost:$TRAEFIK_PORT${NC}"
echo -e "Traefik Dashboard: ${GREEN}http://traefik.localhost:8081${NC}"

echo -e "\n${GREEN}Setup completed successfully!${NC}"
echo -e "You can create a steampunk theme with: ${BLUE}./create-steampunk-theme.sh${NC}"
echo -e "You can create a Next.js frontend with Storybook and testing with: ${BLUE}./create-nextjs-frontend.sh${NC}"