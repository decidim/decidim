import $ from "jquery"
import "core-js/stable";
import "regenerator-runtime/runtime";
import Configuration from "src/decidim/configuration"

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()

import '../src/evote_check_nota'
import '../src/vizzs/datacharts'

// Images
require.context('../images', true)

// CSS
import './public.scss';

// This needs to be loaded after confirm dialog to bind properly
import Rails from "@rails/ujs"
Rails.start()


