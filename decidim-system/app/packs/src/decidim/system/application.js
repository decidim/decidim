import Rails from "@rails/ujs"
Rails.start()

import $ from 'jquery'
import 'foundation-sites'
import '../../../../../../decidim-core/app/packs/src/decidim/editor'
import '../../../../../../decidim-core/app/packs/src/decidim/input_tags'
import '../../../../../../decidim-core/app/packs/src/decidim/configuration'
import '../../../../../../decidim-core/app/packs/src/decidim/confirm'

$(() => {
  $(document).foundation();
});
