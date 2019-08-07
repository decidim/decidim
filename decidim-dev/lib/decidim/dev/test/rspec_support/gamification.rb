# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    Decidim::Gamification.register_badge(:test) do |badge|
      badge.levels = [1, 5, 10]
      badge.valid_for = [:user, :user_group]
      badge.reset = ->(_user) { 100 }
    end
  end
end
