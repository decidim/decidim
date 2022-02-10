# frozen_string_literal: true

pin "buffer", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.19/nodelibs/browser/buffer.js"

pin "https://cdn.jsdelivr.net/npm/quill@1.3.7/core", to: "https://cdn.jsdelivr.net/npm/quill@1.3.7/core.js"
pin "https://cdn.jsdelivr.net/npm/quill@1.3.7/core/quill", to: "https://cdn.jsdelivr.net/npm/quill@1.3.7/core/quill.js"
pin "https://cdn.jsdelivr.net/npm/quill@1.3.7/core/module", to: "https://cdn.jsdelivr.net/npm/quill@1.3.7/core/module.js"

%w(align direction indent blockquote list background snow bubble header font color size bold italic link script strike underline image video code).each do |lib|
  pin "https://cdn.jsdelivr.net/npm/quill@1.3.7/formats/#{lib}", to: "https://cdn.jsdelivr.net/npm/quill@1.3.7/formats/#{lib}.js"
end
%w( formula toolbar syntax keyboard).each do |lib|
  pin "https://cdn.jsdelivr.net/npm/quill@1.3.7/modules/#{lib}", to: "https://cdn.jsdelivr.net/npm/quill@1.3.7/modules/#{lib}.js"
end
%w(bubble snow).each do |lib|
  pin "https://cdn.jsdelivr.net/npm/quill@1.3.7/themes/#{lib}", to: "https://cdn.jsdelivr.net/npm/quill@1.3.7/themes/#{lib}.js"
end
%w(tooltip color-picker icon-picker picker icons).each do |lib|
  pin "https://cdn.jsdelivr.net/npm/quill@1.3.7/ui/#{lib}", to: "https://cdn.jsdelivr.net/npm/quill@1.3.7/ui/#{lib}.js"
end
%w(block inline embed).each do |lib|
  pin "https://cdn.jsdelivr.net/npm/quill@1.3.7/blots/#{lib}", to: "https://cdn.jsdelivr.net/npm/quill@1.3.7/blots/#{lib}.js"
end

pin "quill", to: "https://cdn.jsdelivr.net/npm/quill@1.3.7/quill.js"
