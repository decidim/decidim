# frozen_string_literal: true

require "active_support/concern"
require "decidim/component_validator"

module Decidim
  # A concern with the components needed when you want a model to have a component.
  module HasComponent
    extend ActiveSupport::Concern

    included do
      belongs_to :component, foreign_key: "decidim_component_id", class_name: "Decidim::Component", touch: true
      delegate :organization, to: :component, allow_nil: true
      delegate :participatory_space, :can_participate_in_space?, to: :component, allow_nil: true

      alias_method :can_participate?, :can_participate_in_space?
    end

    class_methods do
      def component_manifest_name(manifest_name)
        validates :component, component: { manifest: manifest_name || name.demodulize.pluralize.downcase }
      end
    end
  end
end
