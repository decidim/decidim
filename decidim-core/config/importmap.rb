# frozen_string_literal: true

pin "core-js/stable", to: "https://ga.jspm.io/npm:core-js@3.1.3/stable/index.js"
pin "regenerator-runtime/runtime", to: "https://ga.jspm.io/npm:regenerator-runtime@0.13.7/runtime.js"
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.6.0/dist/jquery.js"

pin "buffer", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.19/nodelibs/browser/buffer.js"
pin "quill", to: "https://ga.jspm.io/npm:quill@1.3.7/dist/quill.js"
pin "lodash/defaultsDeep", to: "https://ga.jspm.io/npm:lodash@4.17.4/defaultsDeep.js"

pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@6.0.0/lib/assets/compiled/rails-ujs.js"

pin "foundation-sites", to: "https://ga.jspm.io/npm:foundation-sites@6.7.0/dist/js/foundation.esm.js"

pin "bootstrap-tagsinput", to: "https://ga.jspm.io/npm:bootstrap-tagsinput@0.7.1/dist/bootstrap-tagsinput.js"

pin "jquery-serializejson", to: "https://ga.jspm.io/npm:jquery-serializejson@2.9.0/jquery.serializejson.js"

pin_all_from File.expand_path("../app/packs/src/decidim", __dir__), under: "src/decidim"
