# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to scopes.
  module Scopable
    extend ActiveSupport::Concern

    included do
      belongs_to :scope,
                 foreign_key: "decidim_scope_id",
                 class_name: "Decidim::Scope",
                 optional: true
    end

    # Gets the children scopes of the object's scope.
    #
    # If it's global, returns the organization's top scopes.
    #
    # Returns an ActiveRecord::Relation.
    def subscopes
      scope ? scope.children : organization.top_scopes
    end

    # Whether the resource has subscopes or not.
    #
    # Returns a boolean.
    def has_subscopes?
      scopes_enabled && subscopes.any?
    end
  end
end
