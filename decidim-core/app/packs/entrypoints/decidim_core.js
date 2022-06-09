/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["$"] }] */

import $ from "jquery"
import Quill from "quill"
import Rails from "@rails/ujs"

import "core-js/stable";
import "regenerator-runtime/runtime";
import morphdom from "morphdom"
// Export variable to make it available in .js.erb templates
window.morphdom = morphdom
import "src/decidim/vendor/foundation-datepicker"
import "src/decidim/foundation_datepicker_locales"
import "src/decidim/vendor/modernizr"
import "src/decidim/vendor/social-share-button"

import "src/decidim/input_tags"
import "src/decidim/input_hashtags"
import "src/decidim/input_mentions"
import "src/decidim/input_multiple_mentions"
import "src/decidim/input_character_counter"
import "src/decidim/input_autojump"
import "src/decidim/index"
import "src/decidim/history"
import "src/decidim/callout"
import "src/decidim/clipboard"
import "src/decidim/append_elements"
import "src/decidim/user_registrations"
import "src/decidim/account_form"
import "src/decidim/data_picker"
import "src/decidim/dropdowns_menus"
import "src/decidim/append_redirect_url_to_modals"
import "src/decidim/form_attachments"
import "src/decidim/form_validator"
import "src/decidim/form_remote"
import "src/decidim/ajax_modals"
import "src/decidim/conferences"
import "src/decidim/tooltip_keep_on_hover"
import "src/decidim/diff_mode_dropdown"
import "src/decidim/conversations"
import "src/decidim/delayed"
import "src/decidim/icon"
import "src/decidim/vizzs"
import "src/decidim/responsive_horizontal_tabs"
import "src/decidim/security/selfxss_warning"
import "src/decidim/session_timeouter"
import "src/decidim/configuration"
import "src/decidim/floating_help"
import "src/decidim/confirm"
import "src/decidim/comments/comments"
import "src/decidim/results_listing"
import "src/decidim/represent_user_group"
import "src/decidim/impersonation"
import "src/decidim/start_conversation_dialog"
import "src/decidim/notifications"
import "src/decidim/identity_selector_dialog"
import "src/decidim/gallery"
import "src/decidim/direct_uploads/upload_field"
import "src/decidim/sw"
import "src/decidim/back_to_list"
import "src/decidim/cookie_consent/cookie_consent"

// CSS
import "entrypoints/decidim_core.scss"

// Import from the Rails instance application
import "src/decidim/decidim_application"

// Images
require.context("../images", true)

// This needs to be loaded after confirm dialog to bind properly
Rails.start()
