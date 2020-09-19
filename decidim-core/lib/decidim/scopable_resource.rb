# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to scopes included by resources.
  module ScopableResource
    extend ActiveSupport::Concern

    included do
      include Scopable

      belongs_to :scope,
                 foreign_key: "decidim_scope_id",
                 class_name: "Decidim::Scope",
                 optional: true

      delegate :scopes_enabled, to: :component
    end
  end
end
