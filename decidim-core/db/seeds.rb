# frozen_string_literal: true

require "decidim/core/seeds"

Decidim::Core::Seeds.new.call if !Rails.env.production? || ENV.fetch("SEED", nil)
