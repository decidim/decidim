# frozen_string_literal: true

require "bullet"

RSpec.configure do |config|
  Decidim::ApplicationJob.include(Bullet::ActiveJob) if defined?(Bullet::ActiveJob)

  Rails.application.config.after_initialize do
    Bullet.enable = Decidim::Env.new("DECIDIM_BULLET_ENABLED", "false").present?
    Bullet.rails_logger = true
    Bullet.raise = true
    Bullet.stacktrace_includes = %w(decidim-)

    # Detect N+1 queries
    Bullet.n_plus_one_query_enable = Decidim::Env.new("DECIDIM_BULLET_N_PLUS_ONE", "true").present?
    # Detect eager-loaded associations which are not used
    Bullet.unused_eager_loading_enable = Decidim::Env.new("DECIDIM_BULLET_UNUSED_EAGER", "true").present?
    # Detect unnecessary COUNT queries which could be avoided with a counter_cache
    Bullet.counter_cache_enable = Decidim::Env.new("DECIDIM_BULLET_COUNTER_CACHE", "true").present?
  end

  if Bullet.enable?
    config.before(:each) do
      Bullet.start_request
    end

    config.after(:each) do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
end
