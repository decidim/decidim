# frozen_string_literal: true

if defined?(Bullet) && !Rails.application.config.try(:boost_performance)
  Rails.application.config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
    Bullet.skip_user_in_notification = true
    Bullet.stacktrace_includes = %w(decidim-)
  end
end
