/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["$"] }] */

import $ from "jquery"
import Quill from "quill"
import "foundation-sites"

import createQuillEditor from "src/decidim/editor"
import Configuration from "src/decidim/configuration"

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()

import "src/decidim/input_tags"
import "src/decidim/confirm"

$(() => {
  $(document).foundation();

  $(".editor-container").each((_idx, container) => {
    createQuillEditor(container);
  });
});

// This needs to be loaded after confirm dialog to bind properly
import Rails from "@rails/ujs"
Rails.start()
