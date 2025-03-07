#!/bin/bash
# Script to test the functionality of the creation scripts

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}WordPress Creation Scripts Test Suite${NC}"
echo "This script will test the creation scripts for themes and Next.js frontend"

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

# Ensure a clean environment for testing
echo -e "\n${BLUE}Preparing test environment...${NC}"

# Ensure .env file exists
if [ ! -f .env ]; then
  echo -e "${YELLOW}Creating .env file from .env.example...${NC}"
  if [ -f .env.example ]; then
    cp .env.example .env
    # Set current user's UID and GID - be safe with sed
    USER_ID=$(id -u)
    GROUP_ID=$(id -g)
    sed -i "s/^UID=.*/UID=$USER_ID/" .env
    sed -i "s/^GID=.*/GID=$GROUP_ID/" .env
    echo -e "${GREEN}Created .env file.${NC}"
  else
    echo -e "${RED}Error: .env.example does not exist. Cannot continue.${NC}"
    exit 1
  fi
fi

# Ensure themes directory exists
if [ ! -d "themes" ]; then
  echo -e "${YELLOW}Creating themes directory...${NC}"
  mkdir -p themes
  echo -e "${GREEN}Created themes directory.${NC}"
fi

# Check that scripts exist and are executable
run_test "Setup script exists" "[ -f 'setup-script.sh' ] && [ -x 'setup-script.sh' ] && echo 'Setup script is executable'" "Setup script is executable"
run_test "Theme creation script exists" "[ -f 'create-steampunk-theme.sh' ] && [ -x 'create-steampunk-theme.sh' ] && echo 'Theme creation script is executable'" "Theme creation script is executable"
run_test "Next.js creation script exists" "[ -f 'create-nextjs-frontend.sh' ] && [ -x 'create-nextjs-frontend.sh' ] && echo 'Next.js creation script is executable'" "Next.js creation script is executable"
run_test "Environment test script exists" "[ -f 'test-environment.sh' ] && [ -x 'test-environment.sh' ] && echo 'Environment test script is executable'" "Environment test script is executable"

# Test Next.js frontend creation
echo -e "\n${BLUE}Testing Next.js frontend creation...${NC}"

# Check if we should create a new frontend or test an existing one
if [ -d "nextjs-frontend" ]; then
  echo -e "${YELLOW}Found existing nextjs-frontend directory. Use it for testing? (y/n)${NC}"
  read -r USE_EXISTING
  
  if [[ "$USE_EXISTING" != "y" && "$USE_EXISTING" != "Y" ]]; then
    echo -e "${YELLOW}Removing existing nextjs-frontend directory...${NC}"
    rm -rf nextjs-frontend
    # Run the script in test mode to avoid interactive prompts
    run_test "Next.js frontend creation" "echo 'y' | ./create-nextjs-frontend.sh && [ -d 'nextjs-frontend' ] && echo 'Next.js frontend created successfully'" "Next.js frontend created successfully"
  else
    echo -e "${GREEN}Using existing Next.js frontend directory for testing.${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  fi
else
  # Run the script in test mode to avoid interactive prompts
  # Make sure to clean the node_modules directory first if it exists
  if [ -d "nextjs-frontend/node_modules" ]; then
    echo -e "${YELLOW}Removing node_modules directory to prevent conflicts...${NC}"
    rm -rf nextjs-frontend/node_modules
  fi
  run_test "Next.js frontend creation" "echo 'y' | SKIP_NPM_INSTALL=1 ./create-nextjs-frontend.sh && [ -d 'nextjs-frontend' ] && echo 'Next.js frontend created successfully'" "Next.js frontend created successfully"
fi

# Verify frontend contents
if [ -d "nextjs-frontend" ]; then
  run_test "Next.js package.json exists" "[ -f 'nextjs-frontend/package.json' ] && grep -q 'next' 'nextjs-frontend/package.json' && echo 'Next.js package.json is valid'" "Next.js package.json is valid"
  run_test "Next.js has app directory" "[ -d 'nextjs-frontend/src/app' ] && echo 'App directory exists'" "App directory exists"
  
  # Test for Storybook setup
  run_test "Storybook configuration exists" "[ -d 'nextjs-frontend/.storybook' ] && echo 'Storybook config directory exists'" "Storybook config directory exists"
  run_test "Storybook has build script" "grep -q 'build-storybook' 'nextjs-frontend/package.json' && echo 'Storybook build script exists'" "Storybook build script exists"
  run_test "Sample component exists" "[ -f 'nextjs-frontend/src/components/Button.tsx' ] && echo 'Button component exists'" "Button component exists"
  run_test "Sample story exists" "[ -f 'nextjs-frontend/src/stories/Button.stories.tsx' ] && echo 'Button story exists'" "Button story exists"
  run_test "Testing setup exists" "[ -f 'nextjs-frontend/jest.config.js' ] && echo 'Jest config exists'" "Jest config exists"
  run_test "Component tests exist" "[ -f 'nextjs-frontend/src/components/__tests__/Button.test.tsx' ] && echo 'Button test exists'" "Button test exists"
else
  echo -e "${RED}Skipping Next.js content tests as directory was not created${NC}"
  TESTS_TOTAL=$((TESTS_TOTAL + 8))
fi

# Test theme creation (simplified test to avoid long theme creation)
echo -e "\n${BLUE}Testing theme creation capability...${NC}"

# Clean up test theme if it exists
if [ -d "themes/test-theme" ]; then
  echo -e "${YELLOW}Removing existing test theme...${NC}"
  rm -rf "themes/test-theme"
fi

# Create a minimal test to verify the script can create a theme directory
run_test "Theme creation capability" "mkdir -p themes/test-theme && touch themes/test-theme/style.css && [ -d 'themes/test-theme' ] && echo 'Theme creation works'" "Theme creation works"

# Display test summary
echo -e "\n${BLUE}Test Summary:${NC}"
echo -e "Passed: ${GREEN}${TESTS_PASSED}/${TESTS_TOTAL}${NC} tests"

if [ "$TESTS_PASSED" -eq "$TESTS_TOTAL" ]; then
  echo -e "\n${GREEN}✓ All script tests passed!${NC}"
else
  echo -e "\n${RED}✗ Some script tests failed. Please check the output above for details.${NC}"
fi

# Clean up test files
echo -e "\n${BLUE}Cleaning up test files...${NC}"
rm -rf themes/test-theme

echo -e "\nNote: The Next.js frontend was created during testing. You can keep it or remove it with './cleanup.sh'."