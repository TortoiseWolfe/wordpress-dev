# WordPress Development Environment

A complete development environment for WordPress with a Next.js frontend that communicates with WordPress via its REST API. Supports both local development and production deployment.

## Quick Start

1. Setup environment:

   ```bash
   chmod +x setup-script.sh
   ./setup-script.sh
   ```

   This creates the `.env` file, sets permissions, configures variables, and starts Docker containers.

2. Access services:
   - WordPress: [http://wp.localhost:8000](http://wp.localhost:8000)
   - Next.js: [http://next.localhost:8000](http://next.localhost:8000) (if created)
   - Storybook: [http://storybook.localhost:8000](http://storybook.localhost:8000) (if created)
   - phpMyAdmin: [http://pma.localhost:8000](http://pma.localhost:8000)
   - Traefik Dashboard: [http://traefik.localhost:8081](http://traefik.localhost:8081)

3. Generate a WordPress theme (optional):

   ```bash
   ./create-steampunk-theme.sh
   ```

4. Create a Next.js frontend (optional):

   ```bash
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
   WP_PORT=80  # Port for WordPress site (when not using Traefik)
   WP_DEBUG=1  # Enable WordPress debug mode
   ```

3. **Traefik Configuration**

   ```bash
   TRAEFIK_PORT=8000  # Port for Traefik HTTP entrypoint
   ```

4. **Node.js/Next.js Configuration**

   ```bash
   NODE_ENV=development  # or production
   HOSTNAME=0.0.0.0  # Makes NextJS accessible externally
   PORT=3000  # Next.js port
   ```

5. **Deployment Environment**

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

6. **Theme Configuration**

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

### Test Suite

Test scripts to verify your environment:

```bash
# Complete workflow test (recommended)
./test-complete.sh                     # Uses mock setup (faster)
./test-complete.sh --force-recreate    # Forces recreation of frontend
./test-complete.sh --with-real-creation # Creates actual Next.js frontend

# Individual component tests
./test-environment.sh  # Test environment setup
./test-scripts.sh      # Test creation scripts
```

These tests verify:
- Docker and Docker Compose installation
- Container health and connectivity
- Directory permissions
- Service availability
- Storybook and testing configuration

### Debugging

For troubleshooting:

```bash
./inspect-containers.sh  # Detailed Docker environment info
```

### Cleanup

Reset your environment:

```bash
./cleanup.sh  # Interactive cleanup with confirmation prompts
```

This removes containers, volumes, images, themes, Next.js frontend, and configuration files as needed.

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

The development environment offers two ways to access all services: direct port access and hostname-based routing through Traefik.

### Direct Access:

- **WordPress Site**  
  URL: [http://localhost:80](http://localhost:80) (if WP_PORT=80 in .env)  
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

### Traefik Routing:

- **Traefik Dashboard**  
  URL: [http://traefik.localhost:8081](http://traefik.localhost:8081)  
  *View and manage Traefik routes and services.*

- **WordPress Site**  
  URL: [http://wp.localhost:8000](http://wp.localhost:8000) (or custom port in TRAEFIK_PORT)  
  *Main WordPress site.*

- **Next.js Frontend**  
  URL: [http://next.localhost:8000](http://next.localhost:8000) (or custom port in TRAEFIK_PORT)  
  *Next.js frontend application.*

- **Storybook**  
  URL: [http://storybook.localhost:8000](http://storybook.localhost:8000) (or custom port in TRAEFIK_PORT)  
  *Storybook component library.*

- **phpMyAdmin**  
  URL: [http://pma.localhost:8000](http://pma.localhost:8000) (or custom port in TRAEFIK_PORT)  
  *Database management interface.*

### Setting Up Local Domain Resolution

To use the Traefik hostname-based routing, you need to ensure your computer can resolve the `.localhost` domains. There are multiple ways to set this up:

1. **Option 1: Use Chrome or Edge browser**  
   These browsers automatically resolve `.localhost` domains to 127.0.0.1.

2. **Option 2: Add entries to /etc/hosts file**  
   ```
   127.0.0.1 wp.localhost
   127.0.0.1 next.localhost
   127.0.0.1 storybook.localhost
   127.0.0.1 pma.localhost
   127.0.0.1 traefik.localhost
   ```

3. **Option 3: Use dnsmasq (advanced users)**  
   Configure dnsmasq to resolve all `.localhost` domains to 127.0.0.1.

## Container Names

- `wordpress-dev-traefik` – Traefik reverse proxy and dashboard
- `wordpress-dev-wordpress` – WordPress core application
- `wordpress-dev-nextjs` – Next.js frontend
- `wordpress-dev-storybook` – Storybook component explorer
- `wordpress-dev-phpmyadmin` – phpMyAdmin tool
- `wordpress-dev-db` – MySQL database server

## Traefik Integration

This environment uses Traefik as a reverse proxy to provide:

1. **Hostname-based routing** - Access each service using a readable domain name
2. **Simplified port management** - Single entry point for multiple services
3. **Dashboard for monitoring** - Visual interface showing routes and services
4. **Automatic service discovery** - Detects and routes to Docker containers

### How Traefik Works

Traefik automatically:
- Discovers containers and their labels
- Creates routes based on those labels
- Forwards requests to the appropriate containers

### Configuration Structure

Traefik is configured through:
1. **Command-line arguments** in docker-compose.yaml:
   ```yaml
   command:
     - "--api.insecure=true"  # Enables the dashboard
     - "--providers.docker=true"  # Uses Docker as configuration provider
     - "--entrypoints.web.address=:80"  # Defines HTTP entrypoint
     - "--entrypoints.dashboard.address=:8081"  # Dashboard entrypoint
     - "--providers.docker.network=wp_network"  # Container network to use
     - "--providers.docker.defaultRule=Host(`{{ normalize .Name }}.localhost`)"
   ```

2. **Container labels** that define routing rules:
   ```yaml
   labels:
     - "traefik.enable=true"  # Enable Traefik for this container
     - "traefik.http.routers.wordpress.rule=Host(`wp.localhost`)"  # Domain
     - "traefik.http.routers.wordpress.entrypoints=web"  # Use HTTP entrypoint
     - "traefik.http.services.wordpress.loadbalancer.server.port=80"  # Port
   ```

### Hybrid Access Mode

The current configuration maintains compatibility with both:
- Direct ports (backward compatibility)
- Traefik routing (new hostname-based approach)

You can choose whichever method best suits your workflow.

### Traefik Configuration Options

In your `.env` file, you can customize Traefik behavior:

```bash
TRAEFIK_PORT=8000  # The port where Traefik HTTP entrypoint is accessible
```

### Troubleshooting Traefik

If you encounter issues with Traefik:

1. **Check container connectivity:**
   ```bash
   docker network inspect wordpress-dev_wp_network
   ```
   Verify all containers are on the same network.

2. **Check Traefik logs:**
   ```bash
   docker logs wordpress-dev-traefik
   ```
   Look for error messages about container discovery or routing.

3. **Test domain resolution:**
   ```bash
   ping wp.localhost
   ```
   Should resolve to 127.0.0.1 if your hostname resolution is configured correctly.

4. **Test direct access first:**
   If Traefik routing isn't working, verify you can access services directly
   through their assigned ports.

5. **Access the Traefik dashboard:**
   Visit http://localhost:8081 to check the dashboard and verify routes are properly
   configured.

6. **Restart Traefik:**
   ```bash
   docker compose restart traefik
   ```
   Sometimes Traefik needs a restart to recognize all containers.

This repository contains tools for WordPress theme development, with a focus on rapid theme generation and customization.

## Repository Structure

- `docker-compose.yaml` - Docker setup for Traefik, WordPress, MySQL, phpMyAdmin, Next.js, and Storybook
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
