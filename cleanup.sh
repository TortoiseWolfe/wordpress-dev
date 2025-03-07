#!/bin/bash
# Cleanup script for WordPress Docker development environment

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}WordPress Docker Environment Cleanup${NC}"
echo "This script will clean up your WordPress development environment"
echo -e "${RED}WARNING: This will remove containers, volumes, and generated files${NC}"
echo

# Ask for confirmation
read -p "Are you sure you want to proceed? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo "Cleanup cancelled."
  exit 0
fi

echo -e "\n${BLUE}Stopping all Docker containers...${NC}"
docker-compose down
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Containers stopped successfully${NC}"
else
  echo -e "${RED}Failed to stop containers${NC}"
fi

# Ask if user wants to remove volumes
read -p "Do you want to remove Docker volumes (database, uploads, etc.)? (y/n): " REMOVE_VOLUMES
if [ "$REMOVE_VOLUMES" = "y" ] || [ "$REMOVE_VOLUMES" = "Y" ]; then
  echo -e "\n${BLUE}Removing Docker volumes...${NC}"
  docker-compose down -v
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Volumes removed successfully${NC}"
  else
    echo -e "${RED}Failed to remove volumes${NC}"
  fi
fi

# Ask if user wants to remove Docker images
read -p "Do you want to remove Docker images? (y/n): " REMOVE_IMAGES
if [ "$REMOVE_IMAGES" = "y" ] || [ "$REMOVE_IMAGES" = "Y" ]; then
  echo -e "\n${BLUE}Removing Docker images...${NC}"
  docker rmi wordpress-dev-nextjs wordpress:latest mysql:5.7 phpmyadmin/phpmyadmin 2>/dev/null
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Images removed successfully${NC}"
  else
    echo -e "${YELLOW}Some images could not be removed or did not exist${NC}"
  fi
fi

# Ask if user wants to clean themes directory
read -p "Do you want to clean the themes directory? (y/n): " CLEAN_THEMES
if [ "$CLEAN_THEMES" = "y" ] || [ "$CLEAN_THEMES" = "Y" ]; then
  if [ -d "themes" ]; then
    echo -e "\n${BLUE}Cleaning themes directory...${NC}"
    # Keep only wp default themes (twentytwenty*, index.php)
    find themes/ -type d -not -path "themes/" -not -path "themes/twentytwenty*" -exec rm -rf {} \; 2>/dev/null
    find themes/ -type f -not -name "index.php" -not -path "themes/twentytwenty*/*" -exec rm -f {} \; 2>/dev/null
    echo -e "${GREEN}Themes directory cleaned (WordPress default themes preserved)${NC}"
  else
    echo -e "${YELLOW}Themes directory not found${NC}"
  fi
fi

# Ask if user wants to clean Next.js frontend
if [ -d "nextjs-frontend" ]; then
  read -p "Do you want to remove the Next.js frontend? (y/n): " CLEAN_NEXTJS
  if [ "$CLEAN_NEXTJS" = "y" ] || [ "$CLEAN_NEXTJS" = "Y" ]; then
    echo -e "\n${BLUE}Removing Next.js frontend...${NC}"
    rm -rf nextjs-frontend
    echo -e "${GREEN}Next.js frontend removed${NC}"
  fi
fi

# Ask if user wants to remove .env file
read -p "Do you want to remove the .env file? (y/n): " REMOVE_ENV
if [ "$REMOVE_ENV" = "y" ] || [ "$REMOVE_ENV" = "Y" ]; then
  echo -e "\n${BLUE}Removing .env file...${NC}"
  rm -f .env
  echo -e "${GREEN}.env file removed${NC}"
fi

# Optional Docker system prune
read -p "Do you want to run Docker system prune to clean up unused resources? (y/n): " DOCKER_PRUNE
if [ "$DOCKER_PRUNE" = "y" ] || [ "$DOCKER_PRUNE" = "Y" ]; then
  echo -e "\n${BLUE}Running Docker system prune...${NC}"
  docker system prune -f
  echo -e "${GREEN}Docker system prune completed${NC}"
fi

echo -e "\n${GREEN}Cleanup completed!${NC}"
echo "You can run './setup-script.sh' to set up the environment again."