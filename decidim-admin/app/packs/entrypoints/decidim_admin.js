/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["$"] }] */

import "src/decidim/admin/tab_focus"
import initLanguageChangeSelect from "src/decidim/admin/choose_language"
import "src/decidim/admin/application"
import "src/decidim/admin/resources_permissions"
import "src/decidim/admin/welcome_notification"
import "src/decidim/admin/newsletters"
import "src/decidim/admin/form"
import "src/decidim/admin/external_domain_allowlist"
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

  document.querySelectorAll("input[data-label-preview=true]").forEach((element) => {
    element.addEventListener("change", (event) => {
      // All the update rules are separated by a semicolon, so we split them
      // selector:property:value; selector:property:value;
      //
      // for example:
      //   strong[data-label-preview]:color:#0000ff; strong[data-label-preview]:backgroundColor:#eeeeee;
      const updateRules = event.target.dataset.updates.split(";");

      updateRules.forEach((rule) => {
        const [target, property, value] = rule.split(":");
        document.querySelector(target).style[property.trim()] = value.trim();
      });
    })
  })

  document.querySelectorAll("input[data-text-copy=true], textarea[data-text-copy=true]").forEach((element) => {
    element.addEventListener("change", (event) => {
      const target = document.querySelector(event.target.dataset.target);
      target.innerText = event.target.value;
    })
  });
});
