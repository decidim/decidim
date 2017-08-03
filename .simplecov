SimpleCov.start do
  add_filter "/spec/decidim_dummy_app/"
  add_filter "bundle.js"
  add_filter "/vendor/"
end

if ENV["CI"]
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
