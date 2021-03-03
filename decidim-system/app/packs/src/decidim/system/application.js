import $ from 'jquery'
// TODO-blat: import 'jquery3'
import 'foundation-sites'
require("@rails/ujs").start()
import '../../../../../../decidim-core/app/packs/src/decidim/editor'
import '../../../../../../decidim-core/app/packs/src/decidim/input_tags'
import '../../../../../../decidim-core/app/packs/src/decidim/configuration'
import '../../../../../../decidim-core/app/packs/src/decidim/confirm'

$(() => {
  $(document).foundation();
});
