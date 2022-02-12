/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["$"] }] */
/* eslint no-undef: 0 */

import "core-js/stable";
import "regenerator-runtime/runtime";
import $ from "jquery";
import "quill"
import "foundation-sites"

import Configuration from "src/decidim/configuration"

window.$ = window.jQuery = $;

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()

if (typeof DecidimConfig !== "undefined") {
  Decidim.config.set(DecidimConfig);
}
