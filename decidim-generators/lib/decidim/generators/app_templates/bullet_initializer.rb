# frozen_string_literal: true

if defined?(Bullet) && !Rails.application.config.try(:boost_performance)
  Rails.application.config.after_initialize do
    Bullet.enable = true
    Bullet.raise = true
    Bullet.bullet_logger = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
    Bullet.skip_user_in_notification = true
    Bullet.stacktrace_includes = %w(decidim-)

    # Detect N+1 queries
    Bullet.n_plus_one_query_enable = Decidim::Env.new("DECIDIM_BULLET_N_PLUS_ONE", "true").present?
    # Detect eager-loaded associations which are not used
    Bullet.unused_eager_loading_enable = Decidim::Env.new("DECIDIM_BULLET_UNUSED_EAGER", "true").present?
    # Detect unnecessary COUNT queries which could be avoided with a counter_cache
    Bullet.counter_cache_enable = Decidim::Env.new("DECIDIM_BULLET_COUNTER_CACHE", "true").present?
  end
end
