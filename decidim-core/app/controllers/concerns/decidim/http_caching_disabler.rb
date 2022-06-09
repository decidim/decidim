# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This module will disable http caching from the controller in
  # order to prevent proxies from storing sensible information.
  module HttpCachingDisabler
    extend ActiveSupport::Concern

    included do
      before_action :disable_http_caching
    end

    def disable_http_caching
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
      response.cache_control.replace(no_cache: true, extras: ["no-store"])
    end
  end
end
