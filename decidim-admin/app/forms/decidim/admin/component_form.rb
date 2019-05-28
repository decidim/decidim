# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to attach a component to a participatory process from the
    # admin panel.
    #
    class ComponentForm < Decidim::Form
      include TranslatableAttributes

      mimic :component

      translatable_attribute :name, String
      validates :name, translatable_presence: true

      attribute :settings, Object
      attribute :default_step_settings, Object
      attribute :manifest
      attribute :weight, Integer, default: 0

      attribute :step_settings, Hash[String => Object]
      attribute :participatory_space

      validate :must_be_able_to_change_participatory_texts_setting, if: :proposal_component?

      def settings?
        settings.manifest.attributes.any?
      end

      def default_step_settings?
        default_step_settings.manifest.attributes.any?
      end

      def component
        @component ||= Component.find_by(id: id)
      end

      def proposal_component?
        component&.manifest_name == "proposals"
      end

      # Validation for `Proposals` components. Prevents changing the global
      # setting `participatory_texts_enabled` when there are proposals.
      # Does not add a custom error message as it would be unused, because
      # the setting's checkbox is automatically being disabled on the frontend.
      def must_be_able_to_change_participatory_texts_setting
        return unless settings[:participatory_texts_enabled] &.!= component.settings.participatory_texts_enabled

        errors.add(:settings) if Decidim::Proposals::Proposal.where(component: component).any?
      end
    end
  end
end
