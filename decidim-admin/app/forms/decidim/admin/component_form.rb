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
      validate :amendments_visibility_options_must_be_valid, if: :proposal_component?

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
        form_setting_value = settings[:participatory_texts_enabled].to_i == 1 # Convert "1"/"0" to true/false
        return if form_setting_value == component.settings.participatory_texts_enabled

        errors.add(:settings) if Decidim::Proposals::Proposal.where(component: component).any?
      end

      def amendments_visibility_options_must_be_valid
        return unless component.settings.amendments_enabled
        return unless step_settings.any? do |_step, settings|
          Decidim::Amendment::VisibilityStepSetting.options.map(&:last).exclude? settings[:amendments_visibility]
        end

        errors.add(:settings)
      end
    end
  end
end
