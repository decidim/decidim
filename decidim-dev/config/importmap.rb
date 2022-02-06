# frozen_string_literal: true

pin "crypto", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.19/nodelibs/browser/crypto.js"
pin "process", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.19/nodelibs/browser/process-production.js"
pin "axe-core", to: "https://ga.jspm.io/npm:axe-core@4.1.4/axe.js"

pin "src/decidim/icon"
pin_all_from File.expand_path("../app/packs/src/decidim/dev", __dir__), under: "src/decidim/dev"
