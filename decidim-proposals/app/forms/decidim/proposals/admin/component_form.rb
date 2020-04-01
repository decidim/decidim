# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object for proposals components. Used to attach the component to
      # a participatory process from the admin panel.
      #
      class ComponentForm < Decidim::Admin::ComponentForm
        validate :must_be_able_to_change_participatory_texts_setting
        validate :amendments_visibility_options_must_be_valid

        private

        # Validates setting `participatory_texts_enabled` is not changed when there are proposals for the component.
        def must_be_able_to_change_participatory_texts_setting
          return unless manifest&.name == :proposals && (component = Component.find_by(id: id))
          return unless settings.participatory_texts_enabled != component.settings.participatory_texts_enabled

          settings.errors.add(:participatory_texts_enabled) if Decidim::Proposals::Proposal.where(component: component).any?
        end

        # Validates setting `amendments_visibility` is included in Decidim::Amendment::VisibilityStepSetting.options.
        def amendments_visibility_options_must_be_valid
          return unless manifest&.name == :proposals && settings.amendments_enabled

          visibility_options = Decidim::Amendment::VisibilityStepSetting.options.map(&:last)
          step_settings.each do |step, settings|
            next unless visibility_options.exclude? settings[:amendments_visibility]

            step_settings[step].errors.add(:amendments_visibility, :inclusion)
          end
        end
      end
    end
  end
end
