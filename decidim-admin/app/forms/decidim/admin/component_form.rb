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

      validate :must_be_able_to_update_participatory_texts_setting, if: :proposal_component?

      def settings?
        settings.manifest.attributes.any?
      end

      def default_step_settings?
        default_step_settings.manifest.attributes.any?
      end

      def proposal_component?
        component.manifest_name == "proposals"
      end

      # Custom `Proposals` component validation for the global setting
      # :participatory_texts_enabled. Checkbox's automatically disabled on frontend.
      # Prevents updating ParticipatoryTexts setting when there are proposals.
      def must_be_able_to_update_participatory_texts_setting
        errors.add(:settings) if
        Decidim::Proposals::Proposal.where(component: component).any? &&
        component.settings.participatory_texts_enabled != settings[:participatory_texts_enabled]
      end

      def component
        @component ||= Component.find(id)
      end
    end
  end
end
