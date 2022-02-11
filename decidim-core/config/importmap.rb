# frozen_string_literal: true

pin "@joeattardi/emoji-button", to: "https://ga.jspm.io/npm:@joeattardi/emoji-button@4.6.2/dist/index.js"
pin "@tarekraafat/autocomplete.js", to: "https://ga.jspm.io/npm:@tarekraafat/autocomplete.js@10.2.6/dist/autoComplete.min.js"
pin "@zeitiger/appendaround", to: "https://ga.jspm.io/npm:@zeitiger/appendaround@1.0.0/appendAround.js"
pin "bootstrap-tagsinput", to: "https://ga.jspm.io/npm:bootstrap-tagsinput@0.7.1/dist/bootstrap-tagsinput.js"

pin "core-js/stable", to: "https://ga.jspm.io/npm:core-js@3.1.3/stable/index.js"
pin "regenerator-runtime/runtime", to: "https://ga.jspm.io/npm:regenerator-runtime@0.13.7/runtime.js"
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.6.0/dist/jquery.js"

pin "lodash/defaultsDeep", to: "https://ga.jspm.io/npm:lodash@4.17.4/defaultsDeep.js"

pin "diff", to: "https://ga.jspm.io/npm:diff@5.0.0/lib/index.mjs"

pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@6.0.0/lib/assets/compiled/rails-ujs.js"

pin "foundation-sites", to: "https://ga.jspm.io/npm:foundation-sites@6.7.4/dist/js/foundation.esm.js"


pin "jquery-serializejson", to: "https://ga.jspm.io/npm:jquery-serializejson@2.9.0/jquery.serializejson.js"

pin "morphdom", to: "https://ga.jspm.io/npm:morphdom@2.6.1/dist/morphdom.js"


pin "select", to: "https://ga.jspm.io/npm:select@1.1.2/src/select.js"

pin "svg4everybody", to: "https://ga.jspm.io/npm:svg4everybody@2.1.4/dist/svg4everybody.js"

pin_all_from File.expand_path("../app/packs/src/decidim", __dir__), under: "src/decidim"
