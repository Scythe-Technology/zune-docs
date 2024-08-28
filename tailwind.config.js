/** @type {import('tailwindcss').Config} */
module.exports = {
     content: [
          './style.css',
          './theme.config.jsx',
          './pages/**/*.{js,jsx,ts,tsx,md,mdx}',
     ],
     theme: {
          extend: {}
     },
     darkMode: 'class',
     plugins: []
}