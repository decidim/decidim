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
          if voting_rule_missing?
            settings.errors.add(:vote_rule_threshold_percent_enabled, I18n.t(:budget_voting_rule_required, scope: i18n_error_scope))
            settings.errors.add(:vote_rule_group_1_minimum_budget_projects_enabled, I18n.t(:budget_voting_rule_required, scope: i18n_error_scope))
          end

          if voting_rule_exceed?
            settings.errors.add(:vote_rule_threshold_percent_enabled, I18n.t(:budget_voting_rule_only_one, scope: i18n_error_scope))
            settings.errors.add(:vote_rule_group_1_minimum_budget_projects_enabled, I18n.t(:budget_voting_rule_only_one, scope: i18n_error_scope))
          end
        end

        # - the value must be a valid number
        def budget_voting_rule_value_setting
          return unless manifest&.name == :budgets

          settings.errors.add(:vote_threshold_percent) if invalid_percent_number?
          settings.errors.add(:vote_minimum_budget_projects_number) if invalid_minimum_number?
          settings.errors.add(:vote_maximum_budget_projects_number) if invalid_maximum_number?
        end

        def voting_rule_missing?
          !vote_rule_threshold_percent_enabled? && !vote_rule_minimum_budget_projects_enabled? && !vote_rule_maximum_budget_projects_enabled?
        end

        def voting_rule_exceed?
          vote_rule_threshold_percent_enabled? && (vote_rule_minimum_budget_projects_enabled? || vote_rule_maximum_budget_projects_enabled?)
        end

        def invalid_percent_number?
          return unless vote_rule_threshold_percent_enabled?
          return if vote_threshold_percent.blank?

          vote_threshold_percent.to_i.negative?
        end

        def invalid_minimum_number?
          return unless vote_rule_minimum_budget_projects_enabled?
          return if vote_minimum_budget_projects_number.blank?
          return (vote_minimum_budget_projects_number.to_i > vote_maximum_budget_projects_number) if vote_rule_maximum_budget_projects_enabled?

          vote_minimum_budget_projects_number.to_i < 1
        end

        def invalid_maximum_number?
          return unless vote_rule_maximum_budget_projects_enabled?
          return if vote_maximum_budget_projects_number.blank?
          return (vote_minimum_budget_projects_number.to_i > vote_maximum_budget_projects_number) if vote_rule_minimum_budget_projects_enabled?

          vote_maximum_budget_projects_number.to_i < 1
        end

        def vote_rule_threshold_percent_enabled?
          settings.vote_rule_threshold_percent_enabled
        end

        def vote_threshold_percent
          settings.vote_threshold_percent
        end

        def vote_rule_minimum_budget_projects_enabled?
          settings.vote_rule_group_1_minimum_budget_projects_enabled
        end

        def vote_minimum_budget_projects_number
          settings.vote_minimum_budget_projects_number
        end

        def vote_rule_maximum_budget_projects_enabled?
          settings.vote_rule_group_1_maximum_budget_projects_enabled
        end

        def vote_maximum_budget_projects_number
          settings.vote_maximum_budget_projects_number
        end
      end
    end
  end
end
