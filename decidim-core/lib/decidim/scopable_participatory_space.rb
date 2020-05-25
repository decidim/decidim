# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Specific methods for scoped participatory spaces.
  module ScopableParticipatorySpace
    extend ActiveSupport::Concern

    included do
      include Scopable

      belongs_to :scope,
                 foreign_key: "decidim_scope_id",
                 class_name: "Decidim::Scope",
                 optional: true
    end
  end
end
