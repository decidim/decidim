# frozen_string_literal: true
require "active_support/concern"

module Decidim
  module ActionPermissions
    extend ActiveSupport::Concern

    def authorize_action!(action_name)
      raise "BLAH" unless action_authorized(action_name)
    end

    def action_authorized?(action_name)
      ActionAuthorizer.new(current_user, current_feature, action_name).authorized?
    end
  end
end
