// DO NOT include any javascript file here, but inside the following file instead
import "src/decidim/index"

// Place for custom scripts
import "src/decidim/decidim_application"

// Loads the SVG icons sprite into the page
import "src/decidim/cors_icons"

// CSS
import "entrypoints/decidim_core.scss"
import "stylesheets/decidim/resource_history.scss"

// Images
require.context("../images", true)
