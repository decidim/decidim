# frozen_string_literal: true

require "decidim/dev/engine" if Rails.env.development? || ENV["DECIDIM_DEV_ENGINE"]
