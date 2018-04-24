SimpleCov.start do
  add_filter "/spec/decidim_dummy_app/"
  add_filter "bundle.js"
  add_filter "/vendor/"
  add_filter ".rake"
end

SimpleCov.merge_timeout 1800
