# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # The UserGroups concern must be included in all controllers related
  # to UserGroups feature. It adds a method to enforce that the feature
  # is enabled.
  module UserGroups
    extend ActiveSupport::Concern

    included do
      delegate :user_groups, to: :current_user, prefix: false
      delegate :user_groups_enabled?, to: :current_organization

      helper_method :user_groups, :user_groups_enabled?
    end

    def enforce_user_groups_enabled
      raise Decidim::ActionForbidden unless current_organization.user_groups_enabled?
    end
  end
end
