// Images
require.context("../images", true)

// CSS
import "entrypoints/decidim_dev.scss";
import "src/decidim/dev/accessibility";

window.Decidim = window.Decidim || {};
window.Decidim.dev = true;
