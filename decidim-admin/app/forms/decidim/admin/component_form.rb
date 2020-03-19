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

      attribute :weight, Integer, default: 0

      attribute :manifest, Object
      attribute :participatory_space, Object
      validates :manifest, :participatory_space, presence: true

      attribute :settings, Object
      attribute :default_step_settings, Object
      attribute :step_settings, Hash[String => Object]

      validate :must_be_able_to_change_participatory_texts_setting
      validate :amendments_visibility_options_must_be_valid
      validate :budget_voting_rule_enabled_setting, :budget_voting_rule_value_setting

      def settings?
        settings.manifest.attributes.any?
      end

      def default_step_settings?
        default_step_settings.manifest.attributes.any?
      end

      private

      # Overwrites Rectify::Form#form_attributes_valid? to validate nested `step_settings` attributes.
      def form_attributes_valid?
        return false unless errors.empty? && settings_errors_empty? # Preserves errors from custom validation methods

        attributes_that_respond_to(:valid?).concat(
          step_settings.each_value.select { |attribute| attribute.respond_to?(:valid?) }
        ).all?(&:valid?)
      end

      def settings_errors_empty?
        validations = [settings.errors.empty?]
        validations << if default_step_settings.present?
                         default_step_settings.errors.empty?
                       else
                         step_settings.each_value.map(&:errors).all?(&:empty?)
                       end
        validations.all?
      end

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

      # Validations on budget settings:
      # - a voting rule must be enabled.
      def budget_voting_rule_enabled_setting
        return unless manifest&.name == :budgets

        i18n_error_scope = "decidim.components.budgets.settings.global.form.errors"
        if settings.vote_rule_threshold_percent_enabled.blank? && settings.vote_rule_minimum_budget_projects_enabled.blank?
          settings.errors.add(:vote_rule_threshold_percent_enabled, I18n.t(:budget_voting_rule_required, scope: i18n_error_scope))
          settings.errors.add(:vote_rule_minimum_budget_projects_enabled, I18n.t(:budget_voting_rule_required, scope: i18n_error_scope))
        end

        if settings.vote_rule_threshold_percent_enabled && settings.vote_rule_minimum_budget_projects_enabled
          settings.errors.add(:vote_rule_threshold_percent_enabled, I18n.t(:budget_voting_rule_only_one, scope: i18n_error_scope))
          settings.errors.add(:vote_rule_minimum_budget_projects_enabled, I18n.t(:budget_voting_rule_only_one, scope: i18n_error_scope))
        end
      end

      # - the value must be a valid number
      def budget_voting_rule_value_setting
        return unless manifest&.name == :budgets

        invalid_percent_number = settings.vote_threshold_percent.blank? || settings.vote_threshold_percent.to_i.negative?
        settings.errors.add(:vote_threshold_percent) if settings.vote_rule_threshold_percent_enabled && invalid_percent_number

        invalid_minimum_number = settings.vote_minimum_budget_projects_number.blank? || (settings.vote_minimum_budget_projects_number.to_i < 1)
        settings.errors.add(:vote_minimum_budget_projects_number) if settings.vote_rule_minimum_budget_projects_enabled && invalid_minimum_number
      end
    end
  end
end
