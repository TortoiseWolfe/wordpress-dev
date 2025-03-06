# WordPress Development Environment

This repository contains tools for WordPress theme development, with a focus on rapid theme generation and customization.

## Quick Start

1. Clone this repository

   ```bash
   git clone https://github.com/yourusername/wordpress-dev.git
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
