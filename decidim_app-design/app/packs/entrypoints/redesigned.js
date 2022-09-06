import Configuration from "src/decidim/configuration"
import Dropdowns from "a11y-dropdown-component"

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()

// Images
require.context("../images", true)

// CSS
import "stylesheets/decidim/redesigned_application.scss";

// This needs to be loaded after confirm dialog to bind properly
import Rails from "@rails/ujs"
Rails.start()

document.addEventListener("DOMContentLoaded", () => {
  Dropdowns.init();
})
