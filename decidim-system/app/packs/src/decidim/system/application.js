/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["$"] }] */

import $ from "jquery"
import Quill from "quill"
import "foundation-sites"

import "../../../../../../decidim-core/app/packs/src/decidim/editor"
import "../../../../../../decidim-core/app/packs/src/decidim/input_tags"
import "../../../../../../decidim-core/app/packs/src/decidim/configuration"
import "../../../../../../decidim-core/app/packs/src/decidim/confirm"

$(() => {
  $(document).foundation();
});

// This needs to be loaded after confirm dialog to bind properly
import Rails from "@rails/ujs"
Rails.start()
