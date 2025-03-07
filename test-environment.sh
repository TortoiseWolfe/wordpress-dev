#!/bin/bash
# Test script for WordPress Docker development environment

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}WordPress Docker Environment Test Suite${NC}"
echo "This script will verify your environment is set up correctly"

# Counter for passed tests
TESTS_PASSED=0
TESTS_TOTAL=0

# Function to run a test
run_test() {
  local test_name=$1
  local test_command=$2
  local expected_result=$3
  
  echo -e "\n${BLUE}Testing: ${test_name}${NC}"
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
  
  # Run the command and capture output
  local result
  result=$(eval "$test_command" 2>&1)
  local exit_code=$?
  
  # Check the result
  if [[ "$exit_code" -eq 0 ]]; then
    if [[ -n "$expected_result" && "$result" != *"$expected_result"* ]]; then
      echo -e "${RED}✗ Failed: Output did not contain expected result${NC}"
      echo -e "Expected to contain: $expected_result"
      echo -e "Actual result: $result"
    else
      echo -e "${GREEN}✓ Passed${NC}"
      TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
  else
    echo -e "${RED}✗ Failed: Command exited with code ${exit_code}${NC}"
    echo -e "Command output: $result"
  fi
}

# Ensure .env file exists
if [ ! -f .env ]; then
  echo -e "${YELLOW}Warning: .env file does not exist. Creating from .env.example...${NC}"
  if [ -f .env.example ]; then
    cp .env.example .env
    # Set current user's UID and GID
    sed -i "s/UID=1000/UID=$(id -u)/" .env
    sed -i "s/GID=1000/GID=$(id -g)/" .env
    echo -e "${GREEN}Created .env file.${NC}"
  else
    echo -e "${RED}Error: .env.example does not exist. Cannot continue.${NC}"
    exit 1
  fi
fi

# Load environment variables
source .env

# 1. Test if Docker is running
run_test "Docker daemon is running" "docker info >/dev/null" ""

# 2. Test if docker-compose is installed
run_test "Docker Compose is installed" "docker-compose version >/dev/null" ""

# 3. Test container status
run_test "Checking container status" "docker-compose ps | grep -e 'Up' | wc -l | grep -e '[1-4]'" ""

# 4. Test themes directory permissions
run_test "Themes directory exists and is writable" "[ -d '$THEMES_PATH' ] && [ -w '$THEMES_PATH' ] && echo 'Directory exists and is writable'" "Directory exists and is writable"

# 5. Test WordPress container health
run_test "WordPress container is healthy" "docker-compose ps wordpress | grep 'Up'" "Up"

# 6. Test Database container health
run_test "Database container is healthy" "docker-compose ps db | grep 'Up'" "Up"

# 7. Test WordPress site is reachable (accepts both 200 OK and 302 redirect as valid responses)
run_test "WordPress site is reachable" "STATUS=\$(curl -s -o /dev/null -w '%{http_code}' http://localhost:${WP_PORT:-80}) && ([ \"\$STATUS\" = \"200\" ] || [ \"\$STATUS\" = \"302\" ]) && echo \"WordPress is reachable (HTTP \$STATUS)\"" "WordPress is reachable"

# 8. Test phpMyAdmin is reachable (accepts 200, 302, and 401 as valid responses)
run_test "phpMyAdmin is reachable" "STATUS=\$(curl -s -o /dev/null -w '%{http_code}' http://localhost:${PMA_PORT:-8080}) && ([ \"\$STATUS\" = \"200\" ] || [ \"\$STATUS\" = \"302\" ] || [ \"\$STATUS\" = \"401\" ]) && echo \"phpMyAdmin is reachable (HTTP \$STATUS)\"" "phpMyAdmin is reachable"

# 9. Test Next.js script exists
run_test "Next.js creation script exists" "[ -f 'create-nextjs-frontend.sh' ] && [ -x 'create-nextjs-frontend.sh' ] && echo 'Next.js creation script is executable'" "Next.js creation script is executable"

# 10. Test Next.js container if it exists
if [ -d "nextjs-frontend" ]; then
  run_test "Next.js container is running" "docker-compose ps nextjs | grep 'Up'" "Up"
  run_test "Next.js site is reachable" "STATUS=\$(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000) && ([ \"\$STATUS\" = \"200\" ] || [ \"\$STATUS\" = \"302\" ]) && echo \"Next.js is reachable (HTTP \$STATUS)\"" "Next.js is reachable"
else
  echo -e "\n${YELLOW}Note: Next.js frontend directory doesn't exist yet. You can create it with ./create-nextjs-frontend.sh${NC}"
fi

# 11. Test file creation in themes directory
TEST_FILE="${THEMES_PATH}/test-$(date +%s).txt"
run_test "Can create files in themes directory" "touch '$TEST_FILE' && [ -f '$TEST_FILE' ] && rm '$TEST_FILE' && echo 'File creation successful'" "File creation successful"

# 12. Test permissions in Docker container
run_test "Correct permissions in WordPress container" "docker-compose exec -T wordpress id | grep $(id -u)" "$(id -u)"

# Display test summary
echo -e "\n${BLUE}Test Summary:${NC}"
echo -e "Passed: ${GREEN}${TESTS_PASSED}/${TESTS_TOTAL}${NC} tests"

if [ "$TESTS_PASSED" -eq "$TESTS_TOTAL" ]; then
  echo -e "\n${GREEN}✓ All tests passed! Your environment is set up correctly.${NC}"
else
  echo -e "\n${RED}✗ Some tests failed. Please check the output above for details.${NC}"
  echo -e "Run ${YELLOW}./setup-script.sh${NC} to fix common issues."
fi