# frozen_string_literal: true

if Rails.env.development? && !Rails.application.config.try(:boost_performance)
  require "rack-mini-profiler"

  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)
  Rack::MiniProfiler.config.skip_paths << "/favicon.ico"
  Rack::MiniProfiler.config.position = "bottom-left"
end
