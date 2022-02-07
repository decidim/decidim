# frozen_string_literal: true

pin "@tarekraafat/autocomplete.js", to: "https://ga.jspm.io/npm:@tarekraafat/autocomplete.js@10.2.6/dist/autoComplete.min.js"
pin "html5sortable/dist/html5sortable.es", to: "https://ga.jspm.io/npm:html5sortable@0.10.0/dist/html5sortable.js"
pin "moment", to: "https://ga.jspm.io/npm:moment@2.29.1/moment.js"

pin_all_from File.expand_path("../app/packs/src/decidim", __dir__), under: "src/decidim", preload: true
