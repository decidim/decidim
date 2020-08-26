# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # A form object for the budgets component. Used to attach the component
      # to a participatory process from the admin panel.
      #
      class ComponentForm < Decidim::Admin::ComponentForm
        validate :budget_voting_rule_enabled_setting, :budget_voting_rule_value_setting

        private

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
end
