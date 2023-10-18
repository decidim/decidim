/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["$"] }] */

import "src/decidim/admin/tab_focus"
import initLanguageChangeSelect from "src/decidim/admin/choose_language"
import "src/decidim/admin/application"
import "src/decidim/admin/resources_permissions"
import "src/decidim/admin/welcome_notification"
import "src/decidim/admin/newsletters"
import "src/decidim/admin/form"
import "src/decidim/admin/external_domain_whitelist"
import "src/decidim/admin/draggable-list"
import "src/decidim/admin/sortable"
import "src/decidim/admin/moderations"
import "src/decidim/admin/officializations"
import "src/decidim/slug_form"
import "src/decidim/admin/admin_autocomplete"
import "src/decidim/admin/triadic_color_picker"
import "src/decidim/admin/participatory_space_search"

// CSS
import "entrypoints/decidim_admin.scss";

window.addEventListener("DOMContentLoaded", () => {
  initLanguageChangeSelect(document.querySelectorAll("select.language-change"));
});
