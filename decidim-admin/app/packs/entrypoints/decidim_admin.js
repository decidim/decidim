/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["$"] }] */

import $ from "jquery"
import Quill from "quill"

import "foundation-sites"
import "../../../../decidim-core/app/packs/src/decidim/vendor/foundation-datepicker"
import "../../../../decidim-core/app/packs/src/decidim/foundation_datepicker_locales"
import "jquery.autocomplete"
import "jquery-serializejson"

import "../src/decidim/admin/tab_focus"
import "../src/decidim/admin/choose_language"
import "../src/decidim/admin/application"
import "../src/decidim/admin/resources_permissions"
import "../src/decidim/admin/welcome_notification"
import "../src/decidim/admin/newsletters"
import "../src/decidim/admin/form"
import "../src/decidim/admin/import_guidance"
import "../../../../decidim-core/app/packs/src/decidim/confirm"
import "../src/decidim/admin/draggable-list"
import "../src/decidim/admin/sortable"
import "../../../../decidim-core/app/packs/src/decidim/gallery"
import "../src/decidim/admin/moderations"
import "../../../../decidim-core/app/packs/src/decidim/input_tags"
import "../../../../decidim-core/app/packs/src/decidim/input_hashtags"
import "../../../../decidim-core/app/packs/src/decidim/input_mentions"
import "../../../../decidim-core/app/packs/src/decidim/vizzs"
import "../../../../decidim-core/app/packs/src/decidim/ajax_modals"
import "../src/decidim/admin/officializations"
import "../../../../decidim-core/app/packs/src/decidim/input_character_counter"
import "../../../../decidim-core/app/packs/src/decidim/session_timeouter"
import "../../../../decidim-core/app/packs/src/decidim/slug_form"
import "../../../../decidim-core/app/packs/src/decidim/configuration"
import managedUsersForm from "../src/decidim/admin/managed_users"
window.Decidim.managedUsersForm = managedUsersForm

// This needs to be loaded after confirm dialog to bind properly
import Rails from "@rails/ujs"
Rails.start()
