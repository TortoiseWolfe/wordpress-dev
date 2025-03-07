# WordPress Development Environment

This is a development environment for WordPress with a Next.js frontend that communicates with WordPress via its REST API. The setup supports both local development and production deployment.

## Quick Start

1. Run the setup script to create the environment file and set up permissions:

   ```bash
   chmod +x setup-script.sh
   ./setup-script.sh
   ```

   This script will:
   - Create a `.env` file from `.env.example` if it doesn't exist
   - Set proper permissions for the themes directory
   - Configure Next.js environment variables (if Next.js frontend exists)
   - Start the Docker containers

   **Note on Permissions**: This setup uses the host user's UID/GID in the WordPress container to avoid permission issues. The themes directory is also given 777 permissions to ensure both the container and host user can access it.

2. Once the setup script completes, access the services at:
   - WordPress: [http://localhost:80](http://localhost:80)
   - phpMyAdmin: [http://localhost:8080](http://localhost:8080)
   - Next.js (if set up): [http://localhost:3000](http://localhost:3000)

3. Generate a WordPress theme (optional):

   ```bash
   chmod +x create-steampunk-theme.sh
   ./create-steampunk-theme.sh
   ```

4. Create a Next.js frontend with Storybook and Testing (optional):

   ```bash
   chmod +x create-nextjs-frontend.sh
   ./create-nextjs-frontend.sh
   ```

## Environment Configuration

This project uses a consolidated approach to environment variables, with a single `.env` file that controls all aspects of the development environment. The setup script will automatically create this file from `.env.example` if it doesn't exist.

### Key Environment Variables

The environment variables are organized into categories:

1. **Database Configuration**

   ```bash
   DB_NAME=wordpress
   DB_USER=wordpress
   DB_PASSWORD=wordpress_password
   DB_ROOT_PASSWORD=root_password
   ```

2. **WordPress Configuration**

   ```bash
   WP_PORT=80  # Port for WordPress site
   WP_DEBUG=1  # Enable WordPress debug mode
   ```

3. **Node.js/Next.js Configuration**

   ```bash
   NODE_ENV=development  # or production
   HOSTNAME=0.0.0.0  # Makes NextJS accessible externally
   PORT=3000  # Next.js port
   ```

4. **Deployment Environment**

   ```bash
   # Development mode
   ENVIRONMENT=development
   DOMAIN=localhost

   # Staging mode
   ENVIRONMENT=staging
   
   # Production mode
   ENVIRONMENT=production
   DOMAIN=your-production-domain.com
   ```

5. **Theme Configuration**

   ```bash
   THEME_NAME="Your Theme Name"
   THEME_DESCRIPTION="Theme description"
   THEME_PRIMARY_COLOR="#B87333"  # Copper tone
   # And many more theme-related variables
   ```

### Scripts and Environment Variables

The project's scripts automatically use these environment variables:

- **setup-script.sh**: Creates/updates the `.env` file and configures user permissions
- **create-nextjs-frontend.sh**: Creates a Next.js project with appropriate environment variables
- **create-steampunk-theme.sh**: Generates WordPress themes using theme-related variables

### Network Configuration

The Next.js container is configured to:

- Listen on all network interfaces (0.0.0.0)
- Connect to WordPress via internal Docker network
- Use environment variables for configuration

Important environment variables:

- `HOSTNAME=0.0.0.0` - Makes the server accessible from outside the container
- `PORT=3000` - Sets the port the server listens on
- `NEXT_PUBLIC_WORDPRESS_API_URL` - WordPress REST API endpoint

## Deployment

For production deployment:

1. Ensure you have proper environment variables set in your `.env` file
2. Build and deploy:

   ```bash
   # Build with production configuration
   docker compose -f docker-compose.yaml up -d --build
   ```

## Testing, Debugging, and Maintenance

This repository includes tools to verify your environment is working correctly, to help diagnose issues, and to clean up when needed.

### Test Suite

There are multiple test scripts available to verify your environment:

#### Complete Test (Recommended)

For a comprehensive test of the entire workflow:

```bash
# Standard test using mock setup (faster)
./test-complete.sh

# Force recreation of any existing frontend
./test-complete.sh --force-recreate

# Create a real Next.js frontend with Storybook and run a full test
./test-complete.sh --with-real-creation
```

This test follows the logical workflow a user would follow:

1. Sets up the environment
2. Creates a Next.js frontend with Storybook and testing support
3. Starts all Docker containers
4. Verifies all services are running and accessible
5. Cleans up after completion

The test includes retry logic for service availability and provides detailed output about what's being tested. When running with `--with-real-creation`, it will create an actual Next.js frontend with Storybook rather than using mock files, providing a more thorough but slower test.

#### Individual Component Tests

For testing specific parts of the environment:

```bash
./test-environment.sh  # Test just the environment setup
./test-scripts.sh      # Test just the creation scripts
```

The individual test scripts check:

- Docker and Docker Compose are properly installed
- All containers are running (WordPress, MySQL, Next.js, and Storybook)
- The themes directory has the correct permissions
- Services are reachable on their respective ports
- Storybook is correctly configured and accessible
- Testing setup is properly configured

### Container Inspector

For more detailed debugging information, use the container inspector:

```bash
./inspect-containers.sh
```

This provides comprehensive information about your Docker environment, including:

- Container configurations
- Network settings
- Volume mounts
- Resource usage
- Service-specific information (WordPress version, PHP version, database size, etc.)
- Host system information

### Script Tests

To verify that the creation scripts (for themes and Next.js frontend) work correctly, run:

```bash
./test-scripts.sh
```

This script will:

- Check if all the required scripts exist and are executable
- Test the Next.js frontend creation script
- Verify that Storybook is properly set up
- Check that component tests are created correctly
- Verify that the theme creation process works
- Validate the created files and directories

### Cleanup Script

When you need to clean up your environment (to reset or to free up resources), use the cleanup script:

```bash
./cleanup.sh
```

This interactive script allows you to:

- Stop all Docker containers
- Remove Docker volumes (database, uploads, etc.)
- Remove Docker images
- Clean the themes directory
- Remove the Next.js frontend
- Delete the .env file
- Run Docker system prune to clean up unused resources

Each step requires confirmation, so you can choose exactly what to clean up.

## Useful Docker Commands

```bash
# Stop everything, remove images, clean Docker, rebuild, and restart
docker compose down
docker rmi wordpress-dev-nextjs
docker system prune -af --volumes
docker compose up -d --build --no-cache
```

```bash
# Rebuild and recreate containers without removing volumes
docker compose up -d --build --force-recreate
```

```bash
# View logs for the Next.js frontend
docker compose logs nextjs

# View logs for the WordPress container
docker compose logs wordpress

# Access shell in the WordPress container
docker compose exec wordpress bash
```

## Services & URLs

- **WordPress Site**  
  URL: [http://localhost:80](http://localhost:80)  
  *Main site running the latest WordPress version.*

- **Next.js Frontend**  
  URL: [http://localhost:3000](http://localhost:3000)  
  *React-based frontend interacting with WordPress via the REST API.*

- **Storybook**  
  URL: [http://localhost:6006](http://localhost:6006)  
  *UI component explorer for the Next.js frontend.*

- **phpMyAdmin**  
  URL: [http://localhost:8080](http://localhost:8080)  
  *Web interface for database management.*

- **MySQL Database**  
  Port: `3306`  
  *MySQL 5.7 database storing WordPress data (not browser accessible).*

## Container Names

- `wordpress-dev-wordpress-1` – WordPress core application
- `wordpress-dev-nextjs-1` – Next.js frontend
- `wordpress-dev-storybook-1` – Storybook component explorer
- `wordpress-dev-phpmyadmin-1` – phpMyAdmin tool
- `wordpress-dev-db-1` – MySQL database server

This repository contains tools for WordPress theme development, with a focus on rapid theme generation and customization.

## Repository Structure

- `docker-compose.yaml` - Docker setup for WordPress, MySQL, phpMyAdmin, Next.js, and Storybook
- `create-steampunk-theme.sh` - Script to generate custom WordPress themes
- `create-nextjs-frontend.sh` - Script to create a Next.js frontend with Storybook and testing
- `test-complete.sh` - Complete workflow test script (follows the logical user workflow)
- `test-environment.sh` - Script to verify your environment is set up correctly
- `test-scripts.sh` - Script to test the creation scripts (including Storybook setup)
- `setup-script.sh` - Helper script for environment setup
- `themes/` - Directory where generated themes are stored
- `nextjs-frontend/` - Next.js frontend project (if created)
- `.env.example` - Template for environment variables

## Steampunk Theme Generator

The `create-steampunk-theme.sh` script creates WordPress themes with a steampunk aesthetic, featuring:

- Responsive design with Tailwind CSS
- Dark/light mode toggle
- Modern JavaScript functionality
- Accessible navigation
- Image carousels
- Widget-ready areas
- Custom template tags

### Using Code Folding Regions

The `create-steampunk-theme.sh` script uses code folding regions for better organization. These regions help navigate the large script file by allowing you to collapse sections of code.

#### How to Use Code Folding

- In **VS Code**: Click the small triangles in the gutter next to the region markers to collapse/expand sections
- In **Vim**: Use `zc` to close a fold and `zo` to open a fold
- In **Sublime Text**: Use the small triangles in the gutter or press Ctrl+Shift+[ to fold a region

#### Code Regions in this Repository

The script is organized into the following code regions:

1. **Colors and Setup** - Terminal color definitions and initial setup
2. **Environment Configuration** - Loading variables from .env files
3. **Theme Configuration** - Theme slug and directory preparation
4. **Directory Setup and Assets** - Creating the directory structure
5. **File Creation** - Creating all theme files
   - **Assets - Placeholder Image** - Base64 encoded placeholder image
   - **Theme Files - style.css** - Main theme style file
   - **Theme Files - functions.php** - Core theme functions
   - **Theme Files - carousel-template.php** - Template for image carousel
   - **Theme Files - template-tags.php** - Custom template tags
   - **Theme Files - main.css** - Primary CSS styles
   - **Theme Files - JavaScript** - JS files for interactivity
     - **navigation.js** - Menu navigation functionality
     - **carousel.js** - Image carousel functionality
     - **skip-link-focus-fix.js** - Accessibility improvements
     - **theme-toggle.js** - Dark/light mode toggle
   - **Theme Files - Template Files** - WordPress template files
     - **header.php** - Theme header template
     - **footer.php** - Theme footer template
     - **index.php** - Main index template
     - **sidebar.php** - Sidebar template
     - **page.php** - Single page template
     - **single.php** - Single post template
   - **Additional Files** - Extra template files
     - **home.php** - Homepage template
   - **Configuration Files** - Theme configuration files
     - **package.json** - Node.js package configuration
     - **tailwind.config.js** - Tailwind CSS configuration
     - **tailwind.css** - Tailwind source file
   - **Placeholder CSS** - Temporary CSS files
   - **admin-style.css** - WordPress admin styling
   - **Documentation** - Theme documentation
6. **Color Processing and Theme Building** - Theme color processing and build

## Theme Configuration

The theme configuration is handled through the .env file. Before running the theme generator script, make sure the following variables are set in your `.env` file:

```bash
THEME_NAME="Your Theme Name"
THEME_DESCRIPTION="Your theme description here"
THEME_PRIMARY_COLOR="#B87333"  # Copper color for steampunk theme
THEME_SECONDARY_COLOR="#5C4033"  # Dark brown
THEME_TERTIARY_COLOR="#FFD700"  # Gold
THEME_AUTHOR="Your Name"
THEME_AUTHOR_URI="https://yourwebsite.com"
THEME_PRIMARY_FONT="Special Elite, cursive"
THEME_SECONDARY_FONT="Arbutus Slab, serif"
THEME_TERTIARY_FONT="Cinzel, serif"
```

If this file doesn't exist, the script will create it from the `.env.example` template.

## Docker Environment

The WordPress development environment includes:

- WordPress (latest)
- MySQL (5.7)
- phpMyAdmin (latest)
- Next.js frontend (optional)

Access the services at:

- WordPress: <http://localhost:80>
- phpMyAdmin: <http://localhost:8080>
- Next.js (if created): <http://localhost:3000>

## Developing with Generated Themes

After generating a theme:

1. Install it in WordPress via the admin dashboard
2. Navigate to the theme directory
3. Install dependencies:

   ```bash
   cd themes/your-theme-slug
   npm install
   ```

4. Build the CSS:

   ```bash
   npm run build
   ```

5. For development with auto-refresh:

   ```bash
   npm run watch
   ```

## Customizing Themes

The generated themes include full TailwindCSS support. You can customize:

- Color variables in `tailwind/steampunk-variables.css`
- Component styles in `assets/css/steampunk-theme.css`
- Tailwind configuration in `tailwind.config.js`

## Using Storybook

Storybook is a development environment for UI components. It allows you to:

1. Browse a component library
2. View the different states of each component
3. Interactively develop and test components in isolation

### Storybook in Your Next.js Project

When you create a Next.js frontend using the `create-nextjs-frontend.sh` script, Storybook is automatically set up for you. The setup:

- Installs Storybook and its dependencies
- Configures Storybook for Next.js with App Router
- Creates a sample Button component and story
- Updates package.json with Storybook scripts

### Accessing Storybook

Once set up, you can access Storybook at [http://localhost:6006](http://localhost:6006).

### Creating Stories

To create a new story for a component:

1. Create your component in `src/components/`
2. Create a story file in `src/stories/` with the naming pattern `ComponentName.stories.tsx`

Example story structure:

```tsx
import type { Meta, StoryObj } from '@storybook/react';
import { YourComponent } from '../components/YourComponent';

const meta = {
  title: 'Components/YourComponent',
  component: YourComponent,
  parameters: {
    layout: 'centered',
  },
  tags: ['autodocs'],
} satisfies Meta<typeof YourComponent>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {
  args: {
    // Component props here
  },
};
```

### Updating Storybook

After making changes to your components or stories, you can rebuild and restart the Storybook container:

```bash
docker compose up -d --build storybook
```

### Test-Driven Development

The Next.js frontend comes with a complete testing setup using Jest and React Testing Library:

- **Jest**: JavaScript testing framework with a focus on simplicity
- **React Testing Library**: Testing utilities that encourage good testing practices

#### Running Tests

You can run tests with the following commands:

```bash
# Inside the nextjs-frontend directory
npm test        # Run tests once
npm run test:watch  # Run tests in watch mode during development
```

#### Test Structure

Tests are organized in `__tests__` directories next to the components they test:

``` bash
src/
  components/
    Button.tsx
    __tests__/
      Button.test.tsx
```

#### Writing Tests

Tests follow the React Testing Library pattern, focusing on component behavior rather than implementation details:

```tsx
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { YourComponent } from '../YourComponent';

describe('YourComponent', () => {
  test('should render correctly', () => {
    render(<YourComponent />);
    expect(screen.getByText('Expected Text')).toBeInTheDocument();
  });
  
  test('should respond to user interaction', () => {
    const handleClick = jest.fn();
    render(<YourComponent onClick={handleClick} />);
    
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalled();
  });
});
```

## License

This project is licensed under the GPL v2 or later.
