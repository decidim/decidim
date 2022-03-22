# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # We don't want to reset timeout timer on routes where we make requests automatically
  # (e.g. asking time before timeout or fetching comments).
  module SkipTimeoutable
    extend ActiveSupport::Concern

    private

    def skip_timeout
      request.env["devise.skip_timeoutable"] = true
    end
  end
end
