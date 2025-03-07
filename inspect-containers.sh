#!/bin/bash
# Container inspection script for WordPress Docker development environment

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}WordPress Docker Environment Inspector${NC}"
echo "This script will provide detailed information about your Docker containers"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
  echo -e "${RED}Error: Docker is not running. Please start Docker and try again.${NC}"
  exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
  echo -e "${RED}Error: docker-compose is not installed. Please install it and try again.${NC}"
  exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
  echo -e "${YELLOW}Warning: .env file does not exist. Some tests may fail.${NC}"
fi

# Function to print a section header
print_header() {
  echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}${1}${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Get a list of all containers
CONTAINERS=$(docker-compose ps --services 2>/dev/null)
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Failed to get container list. Is docker-compose.yaml present?${NC}"
  exit 1
fi

# 1. Print Docker and docker-compose versions
print_header "SYSTEM INFORMATION"
echo -e "${BLUE}Docker version:${NC}"
docker --version
echo -e "\n${BLUE}Docker Compose version:${NC}"
docker-compose --version

# 2. Network information
print_header "NETWORK INFORMATION"
echo -e "${BLUE}Docker networks:${NC}"
docker network ls | grep wp_network

echo -e "\n${BLUE}Network inspection:${NC}"
NETWORK_ID=$(docker network ls | grep wp_network | awk '{print $1}')
if [ -n "$NETWORK_ID" ]; then
  docker network inspect $NETWORK_ID | jq '.[0].Name, .[0].Driver, .[0].IPAM.Config'
else
  echo -e "${YELLOW}Network 'wp_network' not found${NC}"
fi

# 3. Container overview
print_header "CONTAINER OVERVIEW"
echo -e "${BLUE}Running containers:${NC}"
docker-compose ps

# 4. Detailed container information
print_header "DETAILED CONTAINER INFORMATION"

for container in $CONTAINERS; do
  echo -e "${GREEN}=== Container: $container ===${NC}\n"
  
  # Skip if container is not running
  if ! docker-compose ps $container | grep -q "Up"; then
    echo -e "${YELLOW}Container is not running${NC}\n"
    continue
  fi
  
  # Show container info
  echo -e "${BLUE}Container ID:${NC}"
  docker-compose ps -q $container
  
  echo -e "\n${BLUE}Container inspection:${NC}"
  docker inspect $(docker-compose ps -q $container) | jq '.[0].Config.User, .[0].Config.Image, .[0].Config.Env | select(. != null)'
  
  echo -e "\n${BLUE}Environment variables:${NC}"
  docker-compose exec -T $container env 2>/dev/null | sort || echo -e "${YELLOW}Could not retrieve environment variables${NC}"
  
  echo -e "\n${BLUE}Volumes:${NC}"
  docker inspect $(docker-compose ps -q $container) | jq '.[0].Mounts | select(. != null)' || echo -e "${YELLOW}Could not retrieve volume information${NC}"
  
  echo -e "\n${BLUE}Resource usage:${NC}"
  docker stats --no-stream $(docker-compose ps -q $container) || echo -e "${YELLOW}Could not retrieve resource usage${NC}"
  
  echo -e "\n${BLUE}Process list:${NC}"
  docker-compose exec -T $container ps aux 2>/dev/null || echo -e "${YELLOW}Could not retrieve process list${NC}"
  
  # Container-specific checks
  case $container in
    wordpress)
      echo -e "\n${BLUE}WordPress version:${NC}"
      docker-compose exec -T wordpress wp --allow-root core version 2>/dev/null || echo -e "${YELLOW}WP-CLI not available${NC}"
      
      echo -e "\n${BLUE}PHP version:${NC}"
      docker-compose exec -T wordpress php -v 2>/dev/null || echo -e "${YELLOW}Could not determine PHP version${NC}"
      
      echo -e "\n${BLUE}Current user in container:${NC}"
      docker-compose exec -T wordpress id 2>/dev/null || echo -e "${YELLOW}Could not determine user in container${NC}"
      ;;
      
    db)
      echo -e "\n${BLUE}MySQL version:${NC}"
      docker-compose exec -T db mysql --version 2>/dev/null || echo -e "${YELLOW}Could not determine MySQL version${NC}"
      
      echo -e "\n${BLUE}Database size:${NC}"
      docker-compose exec -T db mysql -uroot -p${DB_ROOT_PASSWORD:-root_password} -e "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.TABLES GROUP BY table_schema;" 2>/dev/null || echo -e "${YELLOW}Could not retrieve database size${NC}"
      ;;
      
    nextjs)
      echo -e "\n${BLUE}Node.js version:${NC}"
      docker-compose exec -T nextjs node -v 2>/dev/null || echo -e "${YELLOW}Could not determine Node.js version${NC}"
      
      echo -e "\n${BLUE}Next.js version:${NC}"
      docker-compose exec -T nextjs bash -c "cd /app && npm list next" 2>/dev/null || echo -e "${YELLOW}Could not determine Next.js version${NC}"
      ;;
  esac
  
  echo -e "\n${GREEN}========================================${NC}\n"
done

# 5. Volume information
print_header "VOLUME INFORMATION"
echo -e "${BLUE}Docker volumes:${NC}"
docker volume ls | grep wordpress-dev

echo -e "\n${BLUE}Themes directory:${NC}"
if [ -d "themes" ]; then
  ls -la themes
  echo -e "\n${BLUE}Themes directory permissions:${NC}"
  stat -c "%a %u:%g %n" themes
else
  echo -e "${YELLOW}Themes directory not found${NC}"
fi

# 6. Host system information
print_header "HOST SYSTEM INFORMATION"
echo -e "${BLUE}Disk space:${NC}"
df -h .

echo -e "\n${BLUE}Memory usage:${NC}"
free -h

echo -e "\n${BLUE}Current user:${NC}"
id

echo -e "\n${BLUE}Project directory:${NC}"
pwd

echo -e "\n${GREEN}Inspection completed!${NC}"
echo -e "Use this information for debugging or when reporting issues."