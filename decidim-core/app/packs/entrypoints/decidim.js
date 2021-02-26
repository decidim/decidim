// TODO-blat: React/Typescript bundle for the autocomplete component
// import 'src/decidim/core/bundle.js'
// import 'src/decidim/core/extrapoly.js'

import $ from 'jquery'
// TODO-blat: import 'jquery3'
require("@rails/ujs").start()
import 'src/decidim/foundation'

// External dependencies
// TODO-blat: is necessary?
// import Modernizr from 'modernizr'
import 'svg4everybody'
import 'morphdom'
import 'moment'
import 'foundation-datepicker'

import 'src/decidim/form_datepicker'
import 'src/decidim/history'
import 'src/decidim/callout'
import 'src/decidim/append_elements'
import 'src/decidim/user_registrations'
import 'src/decidim/account_form'
import 'src/decidim/data_picker'
import 'src/decidim/dropdowns_menus'
import 'src/decidim/append_redirect_url_to_modals'
import 'src/decidim/editor'
import 'src/decidim/form_validator'
import 'src/decidim/input_tags'
import 'src/decidim/input_hashtags'
import 'src/decidim/input_mentions'
import 'src/decidim/input_multiple_mentions'
import 'src/decidim/input_character_counter'
import 'src/decidim/ajax_modals'
import 'src/decidim/conferences'
import 'src/decidim/tooltip_keep_on_hover'
import 'src/decidim/diff_mode_dropdown'
import 'src/decidim/check_boxes_tree'
import 'src/decidim/conversations'
import 'src/decidim/delayed'
import 'src/decidim/icon'
import 'src/decidim/external_link'
import 'src/decidim/vizzs'
import 'src/decidim/responsive_horizontal_tabs'
import 'src/decidim/geocoding/attach_input'
import 'src/decidim/security/selfxss_warning'
import 'src/decidim/session_timeouter'
import 'src/decidim/configuration'
// TODO-blat: this file is a .js.erb
// import 'src/decidim/assets'
import 'src/decidim/floating_help'


// import 'jquery-ujs'
// NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.$ = global.jQuery = $

