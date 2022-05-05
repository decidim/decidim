# frozen_string_literal: true

require "decidim/dev/engine" if Rails.env.development? || ENV.fetch("DECIDIM_DEV_ENGINE", nil)
