# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    Decidim::Gamification.register_badge(:test) do |badge|
      badge.levels = [1, 5, 10]
      badge.reset = ->(_user) { 100 }
    end
  end
end
