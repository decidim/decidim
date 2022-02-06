import "core-js/stable";
import "regenerator-runtime/runtime";
import $ from 'jquery';
import Quill from "quill"
import "foundation-sites"

import Configuration from "src/decidim/configuration"

window.Quill = Quill;
window.$ = window.jQuery = $;

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()

if (typeof DecidimConfig !== "undefined") {
  Decidim.config.set(DecidimConfig);
}
