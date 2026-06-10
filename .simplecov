# frozen_string_literal: true

if ENV["SIMPLECOV"]
  SimpleCov.start do
    # `ENGINE_ROOT` holds the name of the engine we are testing.
    # This brings us to the main Decidim folder.
    root File.expand_path("..", ENV.fetch("ENGINE_ROOT", nil))

    # We make sure we track all Ruby files, to avoid skipping unrequired files
    # We need to include the `../` section, otherwise it only tracks files from the
    # `ENGINE_ROOT` folder for some reason.
    track_files "../**/*.rb"

    # We ignore some of the files because they are never tested
    skip "/config/"
    skip "/db/"
    skip "/vendor/"
    skip "/spec/"
    skip "/test/"
    skip %r{^/decidim-[^/]*/lib/decidim/[^/]*/engine.rb}
    skip %r{^/decidim-[^/]*/lib/decidim/[^/]*/admin-engine.rb}
    skip %r{^/decidim-[^/]*/lib/decidim/[^/]*/component.rb}
    skip %r{^/decidim-[^/]*/lib/decidim/[^/]*/participatory_space.rb}
  end

  SimpleCov.merge_timeout 1800

  SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter if ENV["CI"]
end
