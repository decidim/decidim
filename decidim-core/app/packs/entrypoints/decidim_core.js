// TODO-blat: React/Typescript bundle for the autocomplete component
// import 'src/decidim/core/bundle.js'
// import 'src/decidim/core/extrapoly.js'

import $ from "jquery"
import Quill from "quill"

// External dependencies
// TODO-blat: is necessary?
// import Modernizr from 'modernizr'

import "core-js/stable";

import "morphdom"
import "foundation-datepicker"
import "social-share-button"

import "../src/decidim/input_tags"
import "../src/decidim/input_hashtags"
import "../src/decidim/input_mentions"
import "../src/decidim/input_multiple_mentions"
import "../src/decidim/input_character_counter"

import "../src/decidim/index"
import "../src/decidim/history"
import "../src/decidim/callout"
import "../src/decidim/append_elements"
import "../src/decidim/user_registrations"
import "../src/decidim/account_form"
import "../src/decidim/data_picker"
import "../src/decidim/dropdowns_menus"
import "../src/decidim/append_redirect_url_to_modals"
import "../src/decidim/editor"
import "../src/decidim/form_validator"
import "../src/decidim/ajax_modals"
import "../src/decidim/conferences"
import "../src/decidim/tooltip_keep_on_hover"
import "../src/decidim/diff_mode_dropdown"
import "../src/decidim/check_boxes_tree"
import "../src/decidim/conversations"
import "../src/decidim/delayed"
import "../src/decidim/icon"
import "../src/decidim/vizzs"
import "../src/decidim/responsive_horizontal_tabs"
import "../src/decidim/security/selfxss_warning"
import "../src/decidim/session_timeouter"
import "../src/decidim/configuration"
import "../src/decidim/assets"
import "../src/decidim/floating_help"
import "../src/decidim/confirm"
import "../../../../decidim-comments/app/packs/src/decidim/comments/comments"
import "../src/decidim/results_listing"
import "../src/decidim/map"
import "../src/decidim/represent_user_group"
import "../src/decidim/impersonation"
import "../src/decidim/start_conversation_dialog"
import "../src/decidim/notifications"
import "../src/decidim/identity_selector_dialog"

// This needs to be loaded after confirm dialog to bind properly
import Rails from "@rails/ujs"
Rails.start()


