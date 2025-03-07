# WordPress Development Environment

This is a development environment for WordPress with a Next.js frontend that communicates with WordPress via its REST API. The setup supports both local development and production deployment.

## Quick Start

1. Copy the environment sample file and customize it:
   ```bash
   cp .env.sample .env
   ```

2. Start the development environment:
   ```bash
   docker compose up -d --build
   ```

3. Access the services at the URLs listed below.

## Environment Configuration

This project uses environment variables for configuration. You can specify:

- **Development Mode**:
  ```bash
  # In .env file
  NODE_ENV=development
  ENVIRONMENT=development
  ```

- **Staging Mode**:
  ```bash
  # In .env file
  NODE_ENV=production
  ENVIRONMENT=staging
  ```

- **Production Mode**:
  ```bash
  # In .env file
  NODE_ENV=production
  ENVIRONMENT=production
  DOMAIN=your-production-domain.com
  ```

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

- **phpMyAdmin**  
  URL: [http://localhost:8080](http://localhost:8080)  
  *Web interface for database management.*

- **MySQL Database**  
  Port: `3306`  
  *MySQL 5.7 database storing WordPress data (not browser accessible).*

## Container Names

- `wordpress-dev-wordpress-1` – WordPress core application
- `wordpress-dev-nextjs-1` – Next.js frontend
- `wordpress-dev-phpmyadmin-1` – phpMyAdmin tool
- `wordpress-dev-db-1` – MySQL database server


This repository contains tools for WordPress theme development, with a focus on rapid theme generation and customization.

## Quick Start

1. Clone this repository

   ```bash
   git clone https://github.com/TortoiseWolfe/wordpress-dev.git
   cd wordpress-dev
   ```

2. Run Docker Compose to set up the WordPress environment

   ```bash
   docker-compose up -d
   ```

3. Generate a new WordPress theme

   ```bash
   ./theme-generator.sh
   ```

## Repository Structure

- `docker-compose.yaml` - Docker setup for WordPress, MySQL, and phpMyAdmin
- `theme-generator.sh` - Script to generate custom WordPress themes
- `setup-script.sh` - Helper script for environment setup
- `themes/` - Directory where generated themes are stored

## Theme Generator Script

The `theme-generator.sh` script creates WordPress themes with a steampunk aesthetic, featuring:

- Responsive design with Tailwind CSS
- Dark/light mode toggle
- Modern JavaScript functionality
- Accessible navigation
- Image carousels
- Widget-ready areas
- Custom template tags

### Using Code Folding Regions

The `theme-generator.sh` script uses code folding regions for better organization. These regions help navigate the large script file by allowing you to collapse sections of code.

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

Before running the theme generator script, you can create a `.env` file with the following variables:

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

Access the services at:

- WordPress: <http://localhost:8080>
- phpMyAdmin: <http://localhost:8081>

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

## License

This project is licensed under the GPL v2 or later.
