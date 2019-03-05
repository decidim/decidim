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
      delegate :participatory_space, to: :component, allow_nil: true

      def can_participate_in_space?(user)
        return true unless participatory_space.try(:private_space?)
        return false unless user

        participatory_space.users.include?(user)
      end
    end

    class_methods do
      def component_manifest_name(manifest_name)
        validates :component, component: { manifest: manifest_name || name.demodulize.pluralize.downcase }
      end
    end
  end
end
