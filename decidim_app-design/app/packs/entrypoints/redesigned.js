import $ from "jquery"
import "core-js/stable";
import "regenerator-runtime/runtime";

import Configuration from "src/decidim/configuration"

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()

// Images
require.context("../images", true)

// CSS
import "stylesheets/decidim/redesigned_application.scss";

// This needs to be loaded after confirm dialog to bind properly
import Rails from "@rails/ujs"
Rails.start()
