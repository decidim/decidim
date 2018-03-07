# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ActionAuthorization
    extend ActiveSupport::Concern
    include Decidim::ActionAuthorizationHelper
  end
end
