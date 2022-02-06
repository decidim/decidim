import "core-js/stable";
import "regenerator-runtime/runtime";
import $ from 'jquery';
import Quill from "quill"
import Rails from "@rails/ujs"
import "foundation-sites"

import Configuration from "src/decidim/configuration"

window.Quill = Quill;
window.Rails = Rails;
window.$ = window.jQuery = $;

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()

if (typeof DecidimConfig !== "undefined") {
  Decidim.config.set(DecidimConfig);
}
console.log(" INIT ")
