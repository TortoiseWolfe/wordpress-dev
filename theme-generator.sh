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

# Read and validate .env variables
if [ ! -f .env ]; then
  echo -e "${RED}Error: .env file not found.${NC}"
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
    
    // Theme specific CSS
    wp_enqueue_style('${THEME_SLUG}-main', get_template_directory_uri() . '/assets/css/main.css', array(), '1.0.0');
    
    // Navigation script
    wp_enqueue_script('${THEME_SLUG}-navigation', get_template_directory_uri() . '/assets/js/navigation.js', array(), '1.0.0', true);
    
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
    const nav = document.querySelector('.main-navigation');
    
    if (menuToggle && nav) {
        menuToggle.addEventListener('click', function() {
            nav.classList.toggle('toggled');
            
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
                <button class="menu-toggle" aria-controls="primary-menu" aria-expanded="false"><?php esc_html_e('Menu', '$THEME_SLUG'); ?></button>
                <?php
                wp_nav_menu(array(
                    'theme_location' => 'primary',
                    'menu_id'        => 'primary-menu',
                    'container'      => false,
                ));
                ?>
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

# Create a README.md file
cat > "$THEME_DIR/README.md" << EOF
# $THEME_NAME WordPress Theme

$THEME_DESCRIPTION

## Features

- Responsive design
- Custom color scheme with CSS variables
- Widget ready and translation ready
- Accessibility enhancements (skip link, focus outlines, ARIA attributes)
- Extended template structure (header, footer, sidebar, page, single, etc.)

## Installation

1. Upload the theme folder to your \`/wp-content/themes/\` directory.
2. Activate the theme through the WordPress admin dashboard.
3. Customize theme options via the WordPress Customizer.

## Credits

- Author: $THEME_AUTHOR
- Created: $(date +"%B %Y")
EOF

# Ensure the themes folder exists
if [ ! -d "themes" ]; then
    mkdir -p "themes"
fi

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
