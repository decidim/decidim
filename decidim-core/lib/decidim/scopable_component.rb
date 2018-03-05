# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to scopes included by components.
  module ScopableComponent
    extend ActiveSupport::Concern

    included do
      include Scopable

      delegate :scopes_enabled, to: :participatory_space
    end
  end
end
