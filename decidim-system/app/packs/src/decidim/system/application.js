/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["$"] }] */

import $ from "jquery"
import Quill from "quill"
import "foundation-sites"

import createQuillEditor from "../../../../../../decidim-core/app/packs/src/decidim/editor"
import Configuration from "../../../../../../decidim-core/app/packs/src/decidim/configuration"

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()

import "../../../../../../decidim-core/app/packs/src/decidim/input_tags"
import "../../../../../../decidim-core/app/packs/src/decidim/confirm"

$(() => {
  $(document).foundation();

  $(".editor-container").each((_idx, container) => {
    createQuillEditor(container);
  });
});

// This needs to be loaded after confirm dialog to bind properly
import Rails from "@rails/ujs"
Rails.start()
