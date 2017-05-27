# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to have a scope.
  module HasScope
    extend ActiveSupport::Concern

    included do
      belongs_to :scope,
                 foreign_key: "decidim_scope_id",
                 class_name: "Decidim::Scope",
                 optional: true
      validate :scope_belongs_to_organization

      private

      def scope_belongs_to_organization
        return if !scope || !feature
        errors.add(:scope, :invalid) unless feature.scopes.where(id: scope.id).exists?
      end
    end
  end
end
