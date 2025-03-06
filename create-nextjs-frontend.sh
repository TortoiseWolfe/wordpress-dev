#!/bin/bash
# create-nextjs-frontend.sh
# This script creates a new Next.js front-end project configured to connect to a WordPress backend.
# It performs the following steps:
#   1. Checks if the "nextjs-frontend" folder exists. If it does, the script exits to prevent overwriting.
#   2. Uses create-next-app (with explicit flags) to scaffold a new Next.js project, forcing npm usage and disabling interactive prompts.
#   3. Creates a .env.local file with environment variables for connecting to the WordPress backend.
#   4. Ensures next.config.js is configured with output: 'standalone' so the build produces a standalone folder.
#   5. Overwrites the default homepage file (in src/app) with a sample implementation that fetches posts from the WordPress REST API.
#      The sample code defines a WPPost interface to avoid explicit "any" type errors.
#   6. Creates a minimal root layout file if one doesn't exist.
#   7. Installs project dependencies using npm.
#
# IMPORTANT:
# - Run this script from your project’s root directory.
# - Ensure that Node.js (>=16.8) and a recent version of npm are installed.
# - The sample homepage and layout code are minimal examples; further customization may be needed.
# - Maintain codebase standards when integrating this script.
#
# Usage:
#   chmod +x create-nextjs-frontend.sh
#   ./create-nextjs-frontend.sh

set -euo pipefail

# Function for error messages.
function error_exit {
  echo "[ERROR] $1" >&2
  exit 1
}

# Check if the nextjs-frontend directory already exists.
if [ -d "./nextjs-frontend" ]; then
  error_exit "Directory 'nextjs-frontend' already exists. Please remove or rename it before running this script."
fi

echo "Creating a new Next.js project in the 'nextjs-frontend' folder..."

# Use CI=true to enforce non-interactive mode.
# Flags:
#   --use-npm                Use npm (creates package-lock.json)
#   --ts                     Enable TypeScript
#   --eslint                 Enable ESLint
#   --tailwind               Configure Tailwind CSS automatically
#   --app                    Use the Next.js 13+ App Router
#   --src-dir                Place files in a /src directory for a cleaner structure
#   --import-alias "@/*"      Set up a custom import alias for shorter imports
#   --no-experimental-turbopack Disable the TurboPack prompt
CI=true npx create-next-app@latest nextjs-frontend \
  --use-npm \
  --ts \
  --eslint \
  --tailwind \
  --app \
  --src-dir \
  --import-alias "@/*" \
  --no-experimental-turbopack \
  || error_exit "Failed to create Next.js project with npx."

echo "Next.js project created successfully."

# Change to the newly created project directory.
cd nextjs-frontend || error_exit "Unable to change directory to 'nextjs-frontend'."

# Create a .env.local file with environment variables for WordPress integration.
cat > .env.local <<'EOF'
# Environment variables for Next.js to connect to the WordPress backend.
WORDPRESS_API_URL=http://wordpress:80/wp-json
NEXT_PUBLIC_WORDPRESS_URL=http://localhost
EOF

echo ".env.local file created with WordPress backend configuration."

# Ensure next.config.js is configured for standalone output.
if [ ! -f "next.config.js" ]; then
  cat > next.config.js <<'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
}
module.exports = nextConfig
EOF
  echo "next.config.js created with output: 'standalone'."
else
  if ! grep -q "output: 'standalone'" next.config.js; then
    echo "module.exports.output = 'standalone';" >> next.config.js
    echo "next.config.js updated with output: 'standalone'."
  else
    echo "next.config.js already configured with output: 'standalone'."
  fi
fi

# Determine the homepage file location.
# With --src-dir enabled, the App Router files are in src/app.
if [ -f "src/app/page.tsx" ]; then
  TARGET_FILE="src/app/page.tsx"
elif [ -f "src/app/page.jsx" ]; then
  TARGET_FILE="src/app/page.jsx"
elif [ -f "pages/index.js" ]; then
  TARGET_FILE="pages/index.js"
else
  # If none exists, create the src/app directory and default to a TypeScript homepage.
  mkdir -p src/app
  TARGET_FILE="src/app/page.tsx"
fi

# Overwrite the determined homepage file with sample code that fetches posts from WordPress.
cat > "$TARGET_FILE" <<'EOF'
import Head from 'next/head';

interface WPPost {
  id: number;
  title: {
    rendered: string;
  };
  excerpt: {
    rendered: string;
  };
}

export default async function Home() {
  let posts: WPPost[] = [];
  try {
    const res = await fetch(`${process.env.WORDPRESS_API_URL}/wp/v2/posts`);
    if (!res.ok) {
      throw new Error('Failed to fetch posts from WordPress API');
    }
    posts = await res.json();
  } catch (error) {
    console.error('Error fetching posts:', error);
  }

  return (
    <div>
      <Head>
        <title>Next.js WordPress Integration</title>
        <meta name="description" content="A Next.js frontend connected to a WordPress backend." />
      </Head>
      <main style={{ padding: '2rem' }}>
        <h1>WordPress Posts</h1>
        {posts.length > 0 ? (
          <ul>
            {posts.map((post: WPPost) => (
              <li key={post.id} style={{ marginBottom: '2rem' }}>
                <h2 dangerouslySetInnerHTML={{ __html: post.title.rendered }} />
                <div dangerouslySetInnerHTML={{ __html: post.excerpt.rendered }} />
              </li>
            ))}
          </ul>
        ) : (
          <p>No posts found or an error occurred while fetching posts.</p>
        )}
      </main>
    </div>
  );
}
EOF

echo "Homepage file '$TARGET_FILE' has been updated with WordPress integration."

# Create a minimal root layout if it doesn't exist.
# For projects using --src-dir, the layout should be in src/app/layout.tsx.
if [ -f "src/app/layout.tsx" ]; then
  echo "Root layout already exists."
else
  mkdir -p src/app
  cat > "src/app/layout.tsx" <<'EOF'
import '../globals.css';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <title>Next.js WordPress Integration</title>
      </head>
      <body>{children}</body>
    </html>
  );
}
EOF
  echo "Root layout file 'src/app/layout.tsx' created."
fi

# Install dependencies using npm (to avoid Yarn workspace issues).
echo "Installing dependencies using npm..."
npm install || error_exit "npm install failed."

echo "Setup complete! Your Next.js front end is now created and connected to the WordPress backend."
echo "You can run the development server using 'npm run dev'."
echo "Remember to integrate this setup carefully with your existing system and adhere to your established codebase standards."
