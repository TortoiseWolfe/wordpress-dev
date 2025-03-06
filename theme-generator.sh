#!/bin/bash
# WordPress Theme Generator Script with zip functionality and extended features

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if zip is installed
if ! command -v zip &> /dev/null; then
    echo -e "${RED}Error: 'zip' command is not installed. Please install it first.${NC}"
    echo "On Ubuntu/Debian: sudo apt-get install zip"
    echo "On CentOS/RHEL: sudo yum install zip"
    echo "On macOS with Homebrew: brew install zip"
    exit 1
fi

# Check for .env file, copy from .env.example if it doesn't exist
if [ ! -f .env ] && [ -f .env.example ]; then
  echo -e "${BLUE}Creating .env file from .env.example...${NC}"
  cp .env.example .env
  echo -e "${GREEN}.env file created. Please edit it with your preferred settings and run the script again.${NC}"
  echo "You can edit the file with: nano .env"
  exit 0
elif [ ! -f .env ]; then
  echo -e "${RED}Error: .env file not found and no .env.example to copy from.${NC}"
  exit 1
fi

# Load variables
source .env

# Validate required variables
if [ -z "$THEME_NAME" ] || [ -z "$THEME_DESCRIPTION" ] || [ -z "$THEME_PRIMARY_COLOR" ] || [ -z "$THEME_AUTHOR" ]; then
  echo -e "${RED}Error: Missing required variables in .env file.${NC}"
  echo "Required variables:"
  echo "  THEME_NAME, THEME_DESCRIPTION, THEME_PRIMARY_COLOR, THEME_AUTHOR"
  exit 1
fi

# Set defaults for optional variables if not defined
THEME_SECONDARY_COLOR=${THEME_SECONDARY_COLOR:-"#4f46e5"}
THEME_TERTIARY_COLOR=${THEME_TERTIARY_COLOR:-"#8b5cf6"}
THEME_PRIMARY_FONT=${THEME_PRIMARY_FONT:-"Poppins"}
THEME_SECONDARY_FONT=${THEME_SECONDARY_FONT:-"Playfair Display"}

# Create theme slug and prefix
THEME_SLUG=$(echo "$THEME_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
THEME_PREFIX=$(echo "$THEME_SLUG" | sed 's/-/_/g')

echo -e "${BLUE}WordPress Theme Generator${NC}"
echo -e "${GREEN}Creating WordPress theme: $THEME_NAME${NC}"
echo "Theme slug: $THEME_SLUG"
echo "Theme prefix: $THEME_PREFIX"

# Create theme directory
THEME_DIR="themes/$THEME_SLUG"

if [ -d "$THEME_DIR" ]; then
  echo -e "${RED}Warning: Theme directory already exists.${NC}"
  read -p "Do you want to overwrite it? (y/n): " OVERWRITE
  if [ "$OVERWRITE" != "y" ]; then
    echo "Theme creation aborted."
    exit 1
  fi
  rm -rf "$THEME_DIR"
fi

# Create directory structure
mkdir -p "$THEME_DIR"
mkdir -p "$THEME_DIR/assets/css"
mkdir -p "$THEME_DIR/assets/js"
mkdir -p "$THEME_DIR/assets/images"
mkdir -p "$THEME_DIR/inc"
mkdir -p "$THEME_DIR/template-parts/content"
mkdir -p "$THEME_DIR/tailwind"

# Create style.css (theme header)
cat > "$THEME_DIR/style.css" << EOF
/*
Theme Name: $THEME_NAME
Author: $THEME_AUTHOR
Author URI: ${THEME_AUTHOR_URI:-""}
Description: $THEME_DESCRIPTION
Version: 1.0.0
License: GNU General Public License v2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html
Text Domain: $THEME_SLUG
Tags: custom
*/

/* This file is used for WordPress to identify the theme */
EOF

# Create functions.php
cat > "$THEME_DIR/functions.php" << EOF
<?php
/**
 * $THEME_NAME Theme functions and definitions
 *
 * @package $THEME_SLUG
 */

// Theme setup
function ${THEME_PREFIX}_setup() {
    // Add default posts and comments RSS feed links to head
    add_theme_support('automatic-feed-links');

    // Let WordPress manage the document title
    add_theme_support('title-tag');

    // Enable support for Post Thumbnails on posts and pages
    add_theme_support('post-thumbnails');

    // Switch default core markup for search form, comment form, and comments to output valid HTML5
    add_theme_support('html5', array(
        'search-form',
        'comment-form',
        'comment-list',
        'gallery',
        'caption',
    ));

    // Register navigation menus
    register_nav_menus(array(
        'primary' => esc_html__('Primary Menu', '$THEME_SLUG'),
        'footer' => esc_html__('Footer Menu', '$THEME_SLUG'),
    ));
}
add_action('after_setup_theme', '${THEME_PREFIX}_setup');

// Enqueue styles and scripts
function ${THEME_PREFIX}_scripts() {
    // Main stylesheet
    wp_enqueue_style('${THEME_SLUG}-style', get_stylesheet_uri(), array(), '1.0.0');
    
    // Tailwind CSS
    wp_enqueue_style('${THEME_SLUG}-tailwind', get_template_directory_uri() . '/assets/css/tailwind.css', array(), '1.0.0');
    
    // Navigation script
    wp_enqueue_script('${THEME_SLUG}-navigation', get_template_directory_uri() . '/assets/js/navigation.js', array(), '1.0.0', true);
    
    // Theme toggle script
    wp_enqueue_script('${THEME_SLUG}-theme-toggle', get_template_directory_uri() . '/assets/js/theme-toggle.js', array(), '1.0.0', true);
    
    // Skip link focus fix
    wp_enqueue_script('${THEME_SLUG}-skip-link-focus-fix', get_template_directory_uri() . '/assets/js/skip-link-focus-fix.js', array(), '1.0.0', true);

    if (is_singular() && comments_open() && get_option('thread_comments')) {
        wp_enqueue_script('comment-reply');
    }
}
add_action('wp_enqueue_scripts', '${THEME_PREFIX}_scripts');

// Register widget area
function ${THEME_PREFIX}_widgets_init() {
    register_sidebar(array(
        'name'          => esc_html__('Sidebar', '$THEME_SLUG'),
        'id'            => 'sidebar-1',
        'description'   => esc_html__('Add widgets here.', '$THEME_SLUG'),
        'before_widget' => '<section id="%1\$s" class="widget %2\$s">',
        'after_widget'  => '</section>',
        'before_title'  => '<h2 class="widget-title">',
        'after_title'   => '</h2>',
    ));
}
add_action('widgets_init', '${THEME_PREFIX}_widgets_init');

// Custom template tags
require get_template_directory() . '/inc/template-tags.php';
EOF

# Create template-tags.php
mkdir -p "$THEME_DIR/inc"
cat > "$THEME_DIR/inc/template-tags.php" << EOF
<?php
/**
 * Custom template tags for this theme
 *
 * @package $THEME_SLUG
 */

if (!function_exists('${THEME_PREFIX}_posted_on')) :
    /**
     * Prints HTML with meta information for post date/time.
     */
    function ${THEME_PREFIX}_posted_on() {
        \$time_string = '<time class="entry-date published updated" datetime="%1\$s">%2\$s</time>';
        
        \$time_string = sprintf(\$time_string,
            esc_attr(get_the_date('c')),
            esc_html(get_the_date())
        );

        echo '<span class="posted-on">' . \$time_string . '</span>';
    }
endif;

if (!function_exists('${THEME_PREFIX}_posted_by')) :
    /**
     * Prints HTML with meta information for the current author.
     */
    function ${THEME_PREFIX}_posted_by() {
        echo '<span class="byline"> ' . esc_html__('by', '$THEME_SLUG') . ' <span class="author vcard"><a href="' . esc_url(get_author_posts_url(get_the_author_meta('ID'))) . '">' . esc_html(get_the_author()) . '</a></span></span>';
    }
endif;
EOF

# Create main.css with accessible, responsive, modern styles
cat > "$THEME_DIR/assets/css/main.css" << EOF
/**
 * Main styles for $THEME_NAME theme
 */

:root {
  /* Theme colors */
  --color-primary: $THEME_PRIMARY_COLOR;
  --color-secondary: ${THEME_SECONDARY_COLOR:-"#666666"};
  --color-accent: ${THEME_TERTIARY_COLOR:-"#333333"};
  --color-background: #ffffff;
  --color-text: #333333;
  
  /* Typography */
  --font-primary: ${THEME_PRIMARY_FONT:-"'Helvetica Neue', Helvetica, Arial"}, sans-serif;
  --font-secondary: ${THEME_SECONDARY_FONT:-"Georgia, serif"};
  --font-size-base: 16px;
  --line-height-base: 1.6;
  
  /* Spacing */
  --spacing-unit: 1rem;
}

/* Reset & Base styles */
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: var(--font-primary);
  font-size: var(--font-size-base);
  line-height: var(--line-height-base);
  color: var(--color-text);
  background-color: var(--color-background);
}

/* Accessible focus outline */
:focus {
  outline: 2px dashed var(--color-primary);
  outline-offset: 2px;
}

h1, h2, h3, h4, h5, h6 {
  font-family: var(--font-secondary);
  margin-bottom: var(--spacing-unit);
  font-weight: 700;
}

a {
  color: var(--color-primary);
  text-decoration: none;
}

a:hover, a:focus {
  text-decoration: underline;
}

img {
  max-width: 100%;
  height: auto;
}

/* Layout */
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 calc(var(--spacing-unit) * 1.5);
}

.site-header {
  padding: var(--spacing-unit) 0;
  margin-bottom: calc(var(--spacing-unit) * 2);
  border-bottom: 1px solid #eee;
}

.site-branding {
  margin-bottom: var(--spacing-unit);
}

.site-title {
  font-size: 2rem;
  font-weight: bold;
  margin-bottom: 0;
}

.site-description {
  font-style: italic;
  color: #666;
}

.site-content {
  display: flex;
  flex-wrap: wrap;
}

.site-main {
  flex: 1;
  min-width: 0;
  padding-right: calc(var(--spacing-unit) * 2);
}

.widget-area {
  flex: 0 0 300px;
}

.site-footer {
  margin-top: calc(var(--spacing-unit) * 3);
  padding: calc(var(--spacing-unit) * 2) 0;
  border-top: 1px solid #eee;
  text-align: center;
  color: #666;
}

/* Navigation */
.main-navigation {
  margin-bottom: var(--spacing-unit);
}

.main-navigation ul {
  display: flex;
  flex-wrap: wrap;
  list-style: none;
}

.main-navigation li {
  margin-right: calc(var(--spacing-unit) * 1.5);
}

.main-navigation a {
  display: block;
  padding: calc(var(--spacing-unit) * 0.5) 0;
}

.menu-toggle {
  display: none;
}

/* Posts */
.entry {
  margin-bottom: calc(var(--spacing-unit) * 3);
}

.entry-header {
  margin-bottom: calc(var(--spacing-unit) * 1.5);
}

.entry-title {
  font-size: 1.8rem;
}

.entry-meta {
  color: #666;
  font-size: 0.9rem;
  margin-top: calc(var(--spacing-unit) * 0.5);
}

.entry-content {
  margin-bottom: calc(var(--spacing-unit) * 1.5);
}

.entry-content p,
.entry-content ul,
.entry-content ol {
  margin-bottom: var(--spacing-unit);
}

.read-more {
  display: inline-block;
  background-color: var(--color-primary);
  color: white;
  padding: calc(var(--spacing-unit) * 0.5) var(--spacing-unit);
  border-radius: 3px;
  font-weight: bold;
}

.read-more:hover {
  background-color: var(--color-secondary);
  text-decoration: none;
}

/* Responsive */
@media (max-width: 768px) {
  .site-content {
    flex-direction: column;
  }
  
  .site-main {
    padding-right: 0;
  }
  
  .widget-area {
    flex: 1;
    width: 100%;
    margin-top: calc(var(--spacing-unit) * 2);
  }
  
  .menu-toggle {
    display: block;
    background: var(--color-primary);
    border: none;
    color: white;
    padding: 0.5rem 1rem;
    margin: 1rem 0;
    cursor: pointer;
  }
  
  .main-navigation ul {
    display: none;
    flex-direction: column;
  }
  
  .main-navigation.toggled ul {
    display: flex;
  }
}
EOF

# Create navigation.js for toggling mobile menu
cat > "$THEME_DIR/assets/js/navigation.js" << EOF
/**
 * File navigation.js.
 *
 * Handles toggling the navigation menu for small screens.
 */
document.addEventListener('DOMContentLoaded', function() {
    const menuToggle = document.querySelector('.menu-toggle');
    const primaryMenu = document.getElementById('primary-menu');
    
    if (menuToggle && primaryMenu) {
        menuToggle.addEventListener('click', function() {
            primaryMenu.classList.toggle('hidden');
            primaryMenu.classList.toggle('flex');
            primaryMenu.classList.toggle('flex-col');
            primaryMenu.classList.toggle('absolute');
            primaryMenu.classList.toggle('bg-white');
            primaryMenu.classList.toggle('dark:bg-gray-800');
            primaryMenu.classList.toggle('shadow-lg');
            primaryMenu.classList.toggle('rounded');
            primaryMenu.classList.toggle('p-4');
            primaryMenu.classList.toggle('mt-2');
            primaryMenu.classList.toggle('left-0');
            primaryMenu.classList.toggle('right-0');
            primaryMenu.classList.toggle('z-50');
            
            if (menuToggle.getAttribute('aria-expanded') === 'true') {
                menuToggle.setAttribute('aria-expanded', 'false');
            } else {
                menuToggle.setAttribute('aria-expanded', 'true');
            }
        });
    }
});
EOF

# Create skip-link-focus-fix.js for accessibility improvements
cat > "$THEME_DIR/assets/js/skip-link-focus-fix.js" << EOF
/**
 * File skip-link-focus-fix.js.
 *
 * Helps with accessibility for keyboard only users.
 */
(function() {
    const isWebkit = navigator.userAgent.toLowerCase().indexOf('webkit') > -1;
    const isOpera = navigator.userAgent.toLowerCase().indexOf('opera') > -1;
    const isIe = navigator.userAgent.toLowerCase().indexOf('msie') > -1;

    if ((isWebkit || isOpera || isIe) && document.getElementById && window.addEventListener) {
        window.addEventListener('hashchange', function() {
            const id = location.hash.substring(1);

            if (!(/^[A-z0-9_-]+$/.test(id))) {
                return;
            }

            const element = document.getElementById(id);

            if (element) {
                if (!(/^(?:a|select|input|button|textarea)$/i.test(element.tagName))) {
                    element.tabIndex = -1;
                }

                element.focus();
            }
        }, false);
    }
})();
EOF

# Create theme-toggle.js for dark/light mode using Tailwind
cat > "$THEME_DIR/assets/js/theme-toggle.js" << EOF
/**
 * File theme-toggle.js.
 *
 * Handles toggling between light and dark theme with Tailwind.
 */
document.addEventListener('DOMContentLoaded', function() {
    // Get the theme toggle button
    const themeToggle = document.getElementById('theme-toggle');
    
    // Check if dark mode is saved in localStorage
    if (localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
        document.documentElement.classList.add('dark');
        updateToggleButton('dark');
    } else {
        document.documentElement.classList.remove('dark');
        updateToggleButton('light');
    }
    
    // Listen for toggle button clicks
    if (themeToggle) {
        themeToggle.addEventListener('click', function() {
            // Toggle dark mode
            if (document.documentElement.classList.contains('dark')) {
                document.documentElement.classList.remove('dark');
                localStorage.theme = 'light';
                updateToggleButton('light');
            } else {
                document.documentElement.classList.add('dark');
                localStorage.theme = 'dark';
                updateToggleButton('dark');
            }
        });
    }
    
    // Update button appearance based on current theme
    function updateToggleButton(theme) {
        if (!themeToggle) return;
        
        if (theme === 'dark') {
            themeToggle.innerHTML = '<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" clip-rule="evenodd"></path></svg>';
            themeToggle.setAttribute('aria-label', 'Switch to light theme');
            themeToggle.classList.remove('bg-gray-200', 'text-gray-800');
            themeToggle.classList.add('bg-gray-700', 'text-yellow-400');
        } else {
            themeToggle.innerHTML = '<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"></path></svg>';
            themeToggle.setAttribute('aria-label', 'Switch to dark theme');
            themeToggle.classList.remove('bg-gray-700', 'text-yellow-400');
            themeToggle.classList.add('bg-gray-200', 'text-gray-800');
        }
    }
});
EOF

# Create header.php with accessible navigation and skip link
cat > "$THEME_DIR/header.php" << EOF
<?php
/**
 * The header for our theme
 *
 * @package $THEME_SLUG
 */
?>
<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="profile" href="https://gmpg.org/xfn/11">
    
    <!-- Load Google Fonts for the theme -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Playfair+Display:wght@400;500;600;700&family=Fira+Code&display=swap" rel="stylesheet">

    <?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
<?php wp_body_open(); ?>
<div id="page" class="site">
    <a class="skip-link screen-reader-text" href="#content"><?php esc_html_e('Skip to content', '$THEME_SLUG'); ?></a>

    <header class="site-header">
        <div class="container">
            <div class="site-branding">
                <?php
                if (has_custom_logo()) :
                    the_custom_logo();
                else :
                ?>
                    <h1 class="site-title"><a href="<?php echo esc_url(home_url('/')); ?>"><?php bloginfo('name'); ?></a></h1>
                    <?php
                    \$description = get_bloginfo('description');
                    if (\$description || is_customize_preview()) :
                    ?>
                        <p class="site-description"><?php echo \$description; ?></p>
                    <?php endif; ?>
                <?php endif; ?>
            </div><!-- .site-branding -->

            <nav id="site-navigation" class="main-navigation" aria-label="<?php esc_attr_e('Primary Menu', '$THEME_SLUG'); ?>">
                <div class="flex-1">
                    <button class="menu-toggle md:hidden px-3 py-2 rounded-xl bg-gradient-to-r from-theme-500 to-theme-600 text-white shadow-md" aria-controls="primary-menu" aria-expanded="false">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                        </svg>
                    </button>
                    <?php
                    wp_nav_menu(array(
                        'theme_location' => 'primary',
                        'menu_id'        => 'primary-menu',
                        'container'      => false,
                        'menu_class'     => 'hidden md:flex',
                    ));
                    ?>
                </div>
                <button id="theme-toggle" aria-label="<?php esc_attr_e('Toggle theme', '$THEME_SLUG'); ?>">
                    <!-- Moon icon -->
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                    </svg>
                </button>
            </nav><!-- #site-navigation -->
        </div><!-- .container -->
    </header><!-- .site-header -->

    <div id="content" class="site-content">
        <div class="container">
EOF

# Create footer.php
cat > "$THEME_DIR/footer.php" << EOF
        </div><!-- .container -->
    </div><!-- #content -->

    <footer id="colophon" class="site-footer">
        <div class="container">
            <div class="site-info">
                &copy; <?php echo date('Y'); ?> <?php bloginfo('name'); ?>
                <?php
                /* translators: %s: Theme author. */
                printf(esc_html__('Theme: %1\$s by %2\$s.', '$THEME_SLUG'), '$THEME_NAME', '$THEME_AUTHOR');
                ?>
            </div><!-- .site-info -->
            
            <?php if (has_nav_menu('footer')) : ?>
                <nav class="footer-navigation" aria-label="<?php esc_attr_e('Footer Menu', '$THEME_SLUG'); ?>">
                    <?php
                    wp_nav_menu(array(
                        'theme_location' => 'footer',
                        'menu_id'        => 'footer-menu',
                        'depth'          => 1,
                        'container'      => false,
                    ));
                    ?>
                </nav>
            <?php endif; ?>
        </div><!-- .container -->
    </footer><!-- #colophon -->
</div><!-- #page -->

<?php wp_footer(); ?>
</body>
</html>
EOF

# Create index.php
cat > "$THEME_DIR/index.php" << EOF
<?php
/**
 * The main template file
 *
 * @package $THEME_SLUG
 */

get_header();
?>

<main id="primary" class="site-main">
    <?php
    if (have_posts()) :
        while (have_posts()) :
            the_post();
            ?>
            <article id="post-<?php the_ID(); ?>" <?php post_class('entry'); ?>>
                <header class="entry-header">
                    <?php the_title('<h2 class="entry-title"><a href="' . esc_url(get_permalink()) . '">', '</a></h2>'); ?>
                    
                    <div class="entry-meta">
                        <?php
                        ${THEME_PREFIX}_posted_on();
                        ${THEME_PREFIX}_posted_by();
                        ?>
                    </div>
                </header>

                <?php if (has_post_thumbnail()) : ?>
                    <div class="entry-thumbnail">
                        <?php the_post_thumbnail('large'); ?>
                    </div>
                <?php endif; ?>

                <div class="entry-content">
                    <?php the_excerpt(); ?>
                    <a href="<?php the_permalink(); ?>" class="read-more"><?php esc_html_e('Read More', '$THEME_SLUG'); ?></a>
                </div>
            </article>
            <?php
        endwhile;

        the_posts_navigation();
    else :
        ?>
        <p><?php esc_html_e('No posts found.', '$THEME_SLUG'); ?></p>
        <?php
    endif;
    ?>
</main>

<?php get_sidebar(); ?>
<?php get_footer(); ?>
EOF

# Create sidebar.php
cat > "$THEME_DIR/sidebar.php" << EOF
<?php
/**
 * The sidebar containing the main widget area
 *
 * @package $THEME_SLUG
 */

if (!is_active_sidebar('sidebar-1')) {
    return;
}
?>

<aside id="secondary" class="widget-area">
    <?php dynamic_sidebar('sidebar-1'); ?>
</aside>
EOF

# Create page.php
cat > "$THEME_DIR/page.php" << EOF
<?php
/**
 * The template for displaying all pages
 *
 * @package $THEME_SLUG
 */

get_header();
?>

<main id="primary" class="site-main">
    <?php
    while (have_posts()) :
        the_post();
        ?>
        <article id="post-<?php the_ID(); ?>" <?php post_class('entry'); ?>>
            <header class="entry-header">
                <?php the_title('<h1 class="entry-title">', '</h1>'); ?>
            </header>

            <?php if (has_post_thumbnail()) : ?>
                <div class="entry-thumbnail">
                    <?php the_post_thumbnail('large'); ?>
                </div>
            <?php endif; ?>

            <div class="entry-content">
                <?php the_content(); ?>
                <?php
                wp_link_pages(array(
                    'before' => '<div class="page-links">' . esc_html__('Pages:', '$THEME_SLUG'),
                    'after'  => '</div>',
                ));
                ?>
            </div>
        </article>
        <?php
        if (comments_open() || get_comments_number()) :
            comments_template();
        endif;
    endwhile;
    ?>
</main>

<?php get_sidebar(); ?>
<?php get_footer(); ?>
EOF

# Create single.php
cat > "$THEME_DIR/single.php" << EOF
<?php
/**
 * The template for displaying all single posts
 *
 * @package $THEME_SLUG
 */

get_header();
?>

<main id="primary" class="site-main">
    <?php
    while (have_posts()) :
        the_post();
        ?>
        <article id="post-<?php the_ID(); ?>" <?php post_class('entry'); ?>>
            <header class="entry-header">
                <?php the_title('<h1 class="entry-title">', '</h1>'); ?>
                
                <div class="entry-meta">
                    <?php
                    ${THEME_PREFIX}_posted_on();
                    ${THEME_PREFIX}_posted_by();
                    ?>
                </div>
            </header>

            <?php if (has_post_thumbnail()) : ?>
                <div class="entry-thumbnail">
                    <?php the_post_thumbnail('large'); ?>
                </div>
            <?php endif; ?>

            <div class="entry-content">
                <?php the_content(); ?>
                <?php
                wp_link_pages(array(
                    'before' => '<div class="page-links">' . esc_html__('Pages:', '$THEME_SLUG'),
                    'after'  => '</div>',
                ));
                ?>
            </div>

            <footer class="entry-footer">
                <?php
                \$categories_list = get_the_category_list(esc_html__(', ', '$THEME_SLUG'));
                if (\$categories_list) {
                    echo '<div class="cat-links">' . esc_html__('Categories: ', '$THEME_SLUG') . \$categories_list . '</div>';
                }
                
                \$tags_list = get_the_tag_list('', esc_html__(', ', '$THEME_SLUG'));
                if (\$tags_list) {
                    echo '<div class="tag-links">' . esc_html__('Tags: ', '$THEME_SLUG') . \$tags_list . '</div>';
                }
                ?>
            </footer>

            <?php
            the_post_navigation(array(
                'prev_text' => '&larr; %title',
                'next_text' => '%title &rarr;',
            ));
            ?>
        </article>
        <?php
        if (comments_open() || get_comments_number()) :
            comments_template();
        endif;
    endwhile;
    ?>
</main>

<?php get_sidebar(); ?>
<?php get_footer(); ?>
EOF

# Create a screenshot.png placeholder (optional)
# You can manually replace this file later with an actual screenshot image
touch "$THEME_DIR/screenshot.png"

# Create package.json for TailwindCSS
cat > "$THEME_DIR/package.json" << EOF
{
  "name": "$THEME_SLUG",
  "version": "1.0.0",
  "description": "$THEME_DESCRIPTION",
  "scripts": {
    "build": "tailwindcss -i ./tailwind/tailwind.css -o ./assets/css/tailwind.css",
    "watch": "tailwindcss -i ./tailwind/tailwind.css -o ./assets/css/tailwind.css --watch"
  },
  "author": "$THEME_AUTHOR",
  "license": "GPL-2.0-or-later",
  "devDependencies": {
    "tailwindcss": "^3.4.1"
  }
}
EOF

# Create tailwind config file with dark mode and custom extensions
cat > "$THEME_DIR/tailwind.config.js" << EOF
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./**/*.php",
    "./assets/js/**/*.js"
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: '$THEME_PRIMARY_COLOR',
        secondary: '${THEME_SECONDARY_COLOR:-"#666666"}',
        tertiary: '${THEME_TERTIARY_COLOR:-"#333333"}',
        // Custom color palette based on primary color
        theme: {
          50: 'hsl(var(--primary-hue), 90%, 95%)',
          100: 'hsl(var(--primary-hue), 85%, 90%)',
          200: 'hsl(var(--primary-hue), 80%, 80%)',
          300: 'hsl(var(--primary-hue), 75%, 70%)',
          400: 'hsl(var(--primary-hue), 70%, 60%)',
          500: 'hsl(var(--primary-hue), 65%, 50%)', // Primary color
          600: 'hsl(var(--primary-hue), 70%, 40%)',
          700: 'hsl(var(--primary-hue), 75%, 30%)',
          800: 'hsl(var(--primary-hue), 80%, 20%)',
          900: 'hsl(var(--primary-hue), 85%, 10%)',
          950: 'hsl(var(--primary-hue), 90%, 5%)',
        },
        // Secondary palette with complementary hue
        accent: {
          50: 'hsl(var(--accent-hue), 90%, 95%)',
          100: 'hsl(var(--accent-hue), 85%, 90%)',
          200: 'hsl(var(--accent-hue), 80%, 80%)', 
          300: 'hsl(var(--accent-hue), 75%, 70%)',
          400: 'hsl(var(--accent-hue), 70%, 60%)',
          500: 'hsl(var(--accent-hue), 65%, 50%)', // Secondary color
          600: 'hsl(var(--accent-hue), 70%, 40%)',
          700: 'hsl(var(--accent-hue), 75%, 30%)',
          800: 'hsl(var(--accent-hue), 80%, 20%)',
          900: 'hsl(var(--accent-hue), 85%, 10%)',
          950: 'hsl(var(--accent-hue), 90%, 5%)',
        }
      },
      fontFamily: {
        sans: ['${THEME_PRIMARY_FONT:-"Poppins"}, ui-sans-serif, system-ui, sans-serif'],
        serif: ['${THEME_SECONDARY_FONT:-"Playfair Display"}, ui-serif, Georgia, serif'],
        display: ['${THEME_SECONDARY_FONT:-"Playfair Display"}, ui-serif, Georgia, serif'],
        mono: ['Fira Code', 'ui-monospace', 'SFMono-Regular', 'monospace']
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-conic': 'conic-gradient(from 225deg, var(--tw-gradient-stops))',
        'diagonal-stripes': 'repeating-linear-gradient(45deg, var(--stripe-color) 0, var(--stripe-color) 1px, transparent 0, transparent 50%)',
        'grid-pattern': 'linear-gradient(var(--grid-color) 1px, transparent 1px), linear-gradient(to right, var(--grid-color) 1px, transparent 1px)',
        'noise': 'url("data:image/svg+xml,%3Csvg viewBox=\'0 0 200 200\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cfilter id=\'noiseFilter\'%3E%3CfeTurbulence type=\'fractalNoise\' baseFrequency=\'0.65\' numOctaves=\'3\' stitchTiles=\'stitch\'/%3E%3C/filter%3E%3Crect width=\'100%\' height=\'100%\' filter=\'url(%23noiseFilter)\'/%3E%3C/svg%3E")',
        'wave-pattern': 'url("data:image/svg+xml,%3Csvg width=\'100%\' height=\'50px\' viewBox=\'0 0 1200 120\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cpath d=\'M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z\' fill=\'rgba(var(--wave-color), 0.08)\'/%3E%3C/svg%3E")',
      },
      boxShadow: {
        'inner-xl': 'inset 0 0 10px 0 rgba(0, 0, 0, 0.1)',
        'glow': '0 0 15px rgba(var(--primary-rgb), 0.5)',
        'glow-lg': '0 0 30px rgba(var(--primary-rgb), 0.3)',
        'sharp': '2px 2px 0 rgba(var(--primary-rgb), 0.8)',
        'neon': '0 0 5px rgba(var(--primary-rgb), 0.5), 0 0 20px rgba(var(--primary-rgb), 0.3), 0 0 40px rgba(var(--primary-rgb), 0.1)',
        'soft': '0 10px 50px rgba(var(--primary-rgb), 0.1)'
      },
      borderRadius: {
        'xl': '1rem',
        '2xl': '1.5rem',
        '3xl': '2rem'
      },
      animation: {
        'float': 'float 6s ease-in-out infinite',
        'gradient': 'gradient 8s linear infinite',
        'pulse-slow': 'pulse 6s cubic-bezier(0.4, 0, 0.6, 1) infinite'
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-10px)' }
        },
        gradient: {
          '0%': { backgroundPosition: '0% 50%' },
          '50%': { backgroundPosition: '100% 50%' },
          '100%': { backgroundPosition: '0% 50%' }
        }
      },
      // Custom background sizes
      backgroundSize: {
        'auto': 'auto',
        'cover': 'cover',
        'contain': 'contain',
        '50%': '50%',
        '16': '4rem',
        '20': '5rem',
        '24': '6rem',
      }
    },
  },
  plugins: [],
}
EOF

# Create base Tailwind CSS file
cat > "$THEME_DIR/tailwind/tailwind.css" << EOF
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    /* Store hex colors directly */
    --color-primary: $THEME_PRIMARY_COLOR;
    --color-secondary: ${THEME_SECONDARY_COLOR};
    --color-tertiary: ${THEME_TERTIARY_COLOR};
    
    /* Convert hex to RGB values for use in rgba() */
    --primary-r: calc(var(--theme-500-r) / 255);
    --primary-g: calc(var(--theme-500-g) / 255);
    --primary-b: calc(var(--theme-500-b) / 255);
    
    /* Extract RGB components for theme colors - these are set in CSS */
    --theme-500-r: 59;  /* Will be replaced by the build process */
    --theme-500-g: 130; /* Will be replaced by the build process */
    --theme-500-b: 246; /* Will be replaced by the build process */
    
    /* Pattern colors */
    --stripe-color: rgba(var(--theme-500-r), var(--theme-500-g), var(--theme-500-b), 0.08);
    --grid-color: rgba(var(--theme-500-r), var(--theme-500-g), var(--theme-500-b), 0.06);
    --wave-color: var(--theme-500-r), var(--theme-500-g), var(--theme-500-b);
  }
  
  /* Enable smooth scrolling */
  html {
    @apply scroll-smooth;
  }
  
  body {
    @apply font-sans text-gray-800 dark:text-gray-200 bg-noise bg-white dark:bg-gray-900 overflow-x-hidden relative;
    background-size: 200px 200px;
    background-blend-mode: overlay;
  }
  
  /* Add fancy background decoration */
  body::before {
    @apply content-[''] absolute top-0 left-0 w-full opacity-10 dark:opacity-5 -z-10 overflow-hidden;
    height: 100vh;
    background-image: radial-gradient(circle at 80% 10%, theme('colors.theme.400'), transparent 40%),
                      radial-gradient(circle at 20% 70%, theme('colors.accent.400'), transparent 30%);
    filter: blur(40px);
  }
  
  /* Wave pattern */
  body::after {
    @apply content-[''] absolute top-0 left-0 w-full h-24 bg-wave-pattern bg-repeat-x bg-bottom -z-20;
    transform: rotate(180deg);
  }
  
  .dark body::after {
    opacity: 0.05;
  }

  h1, h2, h3, h4, h5, h6 {
    @apply font-display font-bold mb-6 text-theme-800 dark:text-theme-100 tracking-tight;
  }

  h1 { 
    @apply text-4xl md:text-5xl xl:text-6xl mb-8 relative;
    text-shadow: 2px 2px 0 rgba(var(--primary-rgb), 0.1);
  }
  
  h1::after {
    @apply content-[''] absolute -bottom-3 left-0 w-16 h-1 bg-gradient-to-r from-theme-500 to-theme-400 rounded-full;
  }
  
  h2 { @apply text-3xl md:text-4xl xl:text-5xl; }
  h3 { @apply text-2xl md:text-3xl; }
  h4 { @apply text-xl md:text-2xl; }
  h5 { @apply text-lg md:text-xl; }
  h6 { @apply text-base md:text-lg; }
  
  a {
    @apply text-theme-600 dark:text-theme-300 hover:text-theme-700 dark:hover:text-theme-200 
      focus:outline-none focus:ring-2 focus:ring-theme-500/50 
      transition-all duration-300 relative;
  }
  
  p {
    @apply mb-6 leading-relaxed;
  }
  
  /* Skip link for accessibility */
  .screen-reader-text {
    @apply sr-only;
  }

  .screen-reader-text:focus {
    @apply not-sr-only bg-white dark:bg-gray-800 text-theme-600 dark:text-theme-400 p-4 absolute left-4 top-4 z-50 rounded-md shadow-lg;
  }
  
  /* Code blocks */
  pre, code {
    @apply font-mono text-sm bg-gray-100 dark:bg-gray-800 p-1 rounded;
  }
  
  pre {
    @apply p-4 my-6 overflow-x-auto;
  }
  
  blockquote {
    @apply pl-4 border-l-4 border-theme-400 dark:border-theme-600 italic my-6 text-gray-700 dark:text-gray-300;
  }
}

@layer components {
  .container {
    @apply mx-auto px-4 sm:px-6 lg:px-8 max-w-7xl;
  }
  
  /* Header Styles */
  .site-header {
    @apply py-4 bg-white/90 dark:bg-gray-900/90 backdrop-blur-sm sticky top-0 z-30 border-b border-gray-100 dark:border-gray-800 shadow-md;
  }
  
  .site-branding {
    @apply mb-2;
  }
  
  .site-title {
    @apply text-3xl font-display font-bold bg-gradient-to-r from-theme-600 via-theme-500 to-accent-500 bg-clip-text text-transparent animate-gradient;
    background-size: 200% auto;
  }
  
  .site-description {
    @apply italic text-gray-600 dark:text-gray-400 text-sm;
  }
  
  /* Theme toggle button */
  #theme-toggle {
    @apply rounded-full p-2 flex items-center justify-center shadow-lg hover:shadow-glow transition-all duration-300;
    animation: float 6s ease-in-out infinite;
  }
  
  /* Content Styles */
  .entry {
    @apply mb-12 bg-white dark:bg-gray-800 rounded-2xl shadow-soft hover:shadow-glow-lg overflow-hidden transition-all duration-500 transform hover:-translate-y-1;
    border: 1px solid rgba(var(--primary-rgb), 0.1);
  }
  
  .entry-title {
    @apply text-2xl font-display text-theme-700 dark:text-theme-300 hover:text-theme-600 dark:hover:text-theme-200;
  }
  
  .entry-header {
    @apply p-6 pb-3 border-b border-gray-100 dark:border-gray-700 relative overflow-hidden;
  }
  
  .entry-header::before {
    @apply content-[''] absolute top-0 left-0 w-full h-full opacity-10 -z-10;
    background-image: radial-gradient(circle at 30% 70%, theme('colors.theme.300'), transparent 50%);
  }
  
  .entry-meta {
    @apply text-gray-600 dark:text-gray-400 text-sm mt-2;
  }
  
  .entry-content {
    @apply p-6;
  }
  
  .entry-thumbnail {
    @apply relative overflow-hidden;
  }
  
  .entry-thumbnail::after {
    @apply content-[''] absolute inset-0 bg-gradient-to-t from-black/30 to-transparent opacity-0 transition-opacity duration-300;
  }
  
  .entry:hover .entry-thumbnail::after {
    @apply opacity-100;
  }
  
  .entry-thumbnail img {
    @apply w-full h-auto transition-transform duration-700 ease-in-out;
  }
  
  .entry:hover .entry-thumbnail img {
    @apply scale-105;
  }
  
  .read-more {
    @apply inline-block bg-gradient-to-r from-theme-500 to-theme-600 hover:from-theme-600 hover:to-accent-500 text-white py-3 px-6 rounded-xl shadow-lg hover:shadow-glow transform hover:-translate-y-1 transition-all duration-300 font-bold no-underline;
  }
  
  /* Widget Styles */
  .widget {
    @apply mb-8 bg-white dark:bg-gray-800 p-6 rounded-2xl shadow-soft border border-gray-100 dark:border-gray-700;
  }
  
  .widget-title {
    @apply text-xl font-display font-bold mb-6 pb-2 border-b border-gray-200 dark:border-gray-700 relative text-theme-700 dark:text-theme-300;
  }
  
  .widget-title:after {
    @apply content-[''] absolute bottom-0 left-0 w-12 h-1 bg-gradient-to-r from-theme-500 to-accent-500 rounded-full;
  }
  
  /* Footer Styles */
  .site-footer {
    @apply mt-20 pt-12 pb-8 bg-gradient-to-b from-white to-gray-50 dark:from-gray-900 dark:to-gray-950 text-center text-gray-600 dark:text-gray-400 border-t border-gray-200 dark:border-gray-800 relative;
  }
  
  .site-footer::before {
    @apply content-[''] absolute top-0 left-0 w-full h-12 bg-wave-pattern bg-repeat-x bg-bottom -translate-y-full;
  }
  
  /* Navigation */
  .main-navigation {
    @apply flex items-center justify-between;
  }
  
  .main-navigation ul {
    @apply flex gap-x-8;
  }
  
  .main-navigation a {
    @apply text-gray-700 dark:text-gray-300 hover:text-theme-600 dark:hover:text-theme-400 hover:no-underline font-medium transition-colors duration-300 py-1 relative;
  }
  
  .main-navigation a:after {
    @apply content-[''] absolute w-0 h-0.5 bg-gradient-to-r from-theme-500 to-theme-400 dark:from-theme-400 dark:to-accent-400 left-0 bottom-0 transition-all duration-500 ease-out rounded-full;
  }
  
  .main-navigation a:hover:after {
    @apply w-full;
  }
  
  /* Comments */
  .comment-list {
    @apply space-y-6;
  }
  
  .comment {
    @apply bg-gray-50 dark:bg-gray-800/50 p-4 rounded-xl;
  }
  
  .comment-author {
    @apply font-bold text-theme-700 dark:text-theme-300;
  }
  
  .comment-metadata {
    @apply text-xs text-gray-500 dark:text-gray-400;
  }
  
  /* Custom utility classes */
  .card {
    @apply bg-white dark:bg-gray-800 rounded-2xl shadow-soft p-6 transition-all duration-300 border border-gray-100 dark:border-gray-700;
  }
  
  .btn {
    @apply inline-block py-2 px-4 rounded-lg shadow-md hover:shadow-lg transform hover:-translate-y-0.5 transition-all duration-300 font-medium;
  }
  
  .btn-primary {
    @apply bg-theme-500 hover:bg-theme-600 text-white;
  }
  
  .btn-secondary {
    @apply bg-accent-500 hover:bg-accent-600 text-white;
  }
  
  .btn-outline {
    @apply border-2 border-theme-500 text-theme-500 hover:bg-theme-500 hover:text-white;
  }
  
  .gradient-text {
    @apply bg-gradient-to-r from-theme-500 to-accent-500 bg-clip-text text-transparent;
  }
}
EOF

# Create a placeholder tailwind.css output file
mkdir -p "$THEME_DIR/assets/css"
cat > "$THEME_DIR/assets/css/tailwind.css" << EOF
/* 
 * Tailwind CSS output file
 * This file will be overwritten when you run npm run build
 */

/* To generate the CSS, run the following commands:
 * cd wp-content/themes/$THEME_SLUG
 * npm install
 * npm run build
 */
EOF

# Create a README.md file
cat > "$THEME_DIR/README.md" << EOF
# $THEME_NAME WordPress Theme

$THEME_DESCRIPTION

## Features

- Modern responsive design built with Tailwind CSS
- Light and dark theme mode with automatic toggle
- Beautiful gradients and drop shadows for a polished look
- Interesting background patterns and visual effects
- Widget ready and translation ready
- Accessibility enhancements (skip link, focus outlines, ARIA attributes)
- Extended template structure (header, footer, sidebar, page, single, etc.)

## Installation

1. Upload the theme folder to your \`/wp-content/themes/\` directory.
2. Activate the theme through the WordPress admin dashboard.
3. Customize theme options via the WordPress Customizer.

## Development

This theme uses Tailwind CSS for styling:

1. Navigate to the theme directory: \`cd wp-content/themes/$THEME_SLUG\`
2. Install dependencies: \`npm install\`
3. Build the CSS: \`npm run build\`
4. For development with auto-refresh: \`npm run watch\`

## Customization

- Tailwind configuration can be modified in \`tailwind.config.js\`
- Base styles and components are defined in \`tailwind/tailwind.css\`
- The light/dark theme toggle is implemented with Tailwind's dark mode class strategy

## Credits

- Author: $THEME_AUTHOR
- Created: $(date +"%B %Y")
EOF

# Ensure the themes folder exists
if [ ! -d "themes" ]; then
    mkdir -p "themes"
fi

# Function to convert hex to RGB
hex_to_rgb() {
  hex=$1
  # Remove # if present
  hex=${hex#"#"}
  
  # Extract r, g, b values
  r=$((16#${hex:0:2}))
  g=$((16#${hex:2:2}))
  b=$((16#${hex:4:2}))
  
  echo "$r $g $b"
}

# Extract RGB values from THEME_PRIMARY_COLOR
read -r r g b <<< $(hex_to_rgb "$THEME_PRIMARY_COLOR")

# Build Tailwind CSS before zipping
echo -e "${BLUE}Extracting color values and building Tailwind CSS...${NC}"
cd "$THEME_DIR"
# Replace default RGB values with actual RGB values from the primary color
# Handle both macOS and Linux sed syntax
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' "s/--theme-500-r: 59;/--theme-500-r: $r;/" ./tailwind/tailwind.css
  sed -i '' "s/--theme-500-g: 130;/--theme-500-g: $g;/" ./tailwind/tailwind.css
  sed -i '' "s/--theme-500-b: 246;/--theme-500-b: $b;/" ./tailwind/tailwind.css
else
  # Linux and others
  sed -i "s/--theme-500-r: 59;/--theme-500-r: $r;/" ./tailwind/tailwind.css
  sed -i "s/--theme-500-g: 130;/--theme-500-g: $g;/" ./tailwind/tailwind.css
  sed -i "s/--theme-500-b: 246;/--theme-500-b: $b;/" ./tailwind/tailwind.css
fi

npm install --quiet
npx tailwindcss -i ./tailwind/tailwind.css -o ./assets/css/tailwind.css
cd ../..

# Now ZIP the theme
echo -e "${BLUE}Creating ZIP archive of the theme...${NC}"
cd themes
zip -r "${THEME_SLUG}.zip" "$THEME_SLUG" -x "*.DS_Store" -x "*.git*" -x "*node_modules*"
cd ..
echo -e "${GREEN}Theme created successfully!${NC}"
echo "Theme location: $THEME_DIR"
echo "ZIP archive: themes/${THEME_SLUG}.zip"
echo ""
echo "To use this theme:"
echo "1. Install WordPress"
echo "2. Go to Appearance > Themes > Add New > Upload Theme"
echo "3. Upload the themes/${THEME_SLUG}.zip file"
echo "4. Activate the theme"
echo ""
echo -e "${BLUE}Theme Features:${NC}"
echo "This theme includes Tailwind CSS with these custom features:"
echo "✓ Beautiful design using your brand colors from .env"
echo "✓ Light/dark mode toggle with animation effects"
echo "✓ Gradient text effects, drop shadows, and animated elements"
echo "✓ Creative background patterns and decorative elements"
echo "✓ Google Fonts integration with Poppins, Playfair Display, and Fira Code"
echo "✓ Responsive design for all devices"
echo ""
echo "For future development:"
echo "1. Navigate to your theme directory: cd $THEME_DIR"
echo "2. Install dependencies: npm install"
echo "3. Make changes to the tailwind/tailwind.css file"
echo "4. Rebuild the CSS: npm run build"
echo "5. For development with auto-refresh: npm run watch"
