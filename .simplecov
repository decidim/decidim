# frozen_string_literal: true

if ENV["SIMPLECOV"]
  # `ENGINE_ROOT` holds the name of the engine we are testing.
  # This brings us to the main Decidim folder.
  SimpleCov.root File.expand_path("..", ENV.fetch("ENGINE_ROOT", nil))

  # We make sure we track all Ruby files, to avoid skipping unrequired files
  # We need to include the `../` section, otherwise it only tracks files from the
  # `ENGINE_ROOT` folder for some reason.
  SimpleCov.cover "../**/*.rb"

  # We ignore some of the files because they are never tested
  SimpleCov.skip "/config/"
  SimpleCov.skip "/db/"
  SimpleCov.skip "/vendor/"
  SimpleCov.skip "/spec/"
  SimpleCov.skip "/test/"
  SimpleCov.skip %r{^/decidim-[^/]*/lib/decidim/[^/]*/engine.rb}
  SimpleCov.skip %r{^/decidim-[^/]*/lib/decidim/[^/]*/admin-engine.rb}
  SimpleCov.skip %r{^/decidim-[^/]*/lib/decidim/[^/]*/component.rb}
  SimpleCov.skip %r{^/decidim-[^/]*/lib/decidim/[^/]*/participatory_space.rb}

  SimpleCov.merge_timeout 1800

  SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter if ENV["CI"]
end
