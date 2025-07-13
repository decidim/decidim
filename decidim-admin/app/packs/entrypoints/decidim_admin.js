/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["$"] }] */

import "src/decidim/admin/tab_focus"
import initLanguageChangeSelect from "src/decidim/admin/choose_language"
import "src/decidim/admin/application"
import "src/decidim/admin/resources_permissions"
import "src/decidim/admin/newsletters"
import "src/decidim/admin/form"
import "src/decidim/admin/external_domain_allowlist"
import "src/decidim/admin/draggable-list"
import "src/decidim/admin/draggable-table"
import "src/decidim/admin/sortable"
import "src/decidim/admin/managed_moderated_users"
import "src/decidim/admin/moderations"
import "src/decidim/admin/global_moderations"
import "src/decidim/admin/officializations"
import "src/decidim/slug_form"
import "src/decidim/admin/admin_autocomplete"
import "src/decidim/admin/triadic_color_picker"
import "src/decidim/admin/participatory_space_search"
import "src/decidim/admin/css_preview"
import "src/decidim/admin/sync_radio_buttons"
import "src/decidim/admin/text_copy"
import "src/decidim/admin/taxonomy_filters"

// CSS
import "entrypoints/decidim_admin.scss";

window.addEventListener("DOMContentLoaded", () => {
  initLanguageChangeSelect(document.querySelectorAll("select.language-change"));
});
