/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["$"] }] */

import "core-js/stable";
import "regenerator-runtime/runtime";
import $ from "jquery"
import Quill from "quill"
import Rails from "@rails/ujs"

import "foundation-sites"
import "src/decidim/vendor/foundation-datepicker"
import "src/decidim/foundation_datepicker_locales"
import "jquery-serializejson"

import "src/decidim/admin/tab_focus"
import initLanguageChangeSelect from "src/decidim/admin/choose_language"
import "src/decidim/admin/application"
import "src/decidim/admin/resources_permissions"
import "src/decidim/admin/welcome_notification"
import "src/decidim/admin/newsletters"
import "src/decidim/admin/form"
import "src/decidim/admin/external_domain_whitelist"
import "src/decidim/confirm"
import "src/decidim/admin/draggable-list"
import "src/decidim/admin/sortable"
import "src/decidim/gallery"
import "src/decidim/admin/moderations"
import "src/decidim/input_tags"
import "src/decidim/input_hashtags"
import "src/decidim/input_mentions"
import "src/decidim/vizzs"
import "src/decidim/ajax_modals"
import "src/decidim/admin/officializations"
import "src/decidim/session_timeouter"
import "src/decidim/slug_form"
import "src/decidim/direct_uploads/upload_field"
import "src/decidim/admin/admin_autocomplete"

// CSS
import "entrypoints/decidim_admin.scss";

// This needs to be loaded after confirm dialog to bind properly
Rails.start()

window.addEventListener("DOMContentLoaded", () => {
  initLanguageChangeSelect(document.querySelectorAll("select.language-change"));
});
