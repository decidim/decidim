# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # A form object for the budgets component. Used to attach the component
      # to a participatory process from the admin panel.
      #
      class ComponentForm < Decidim::Admin::ComponentForm
        validate :budget_voting_rule_enabled_setting,
                 :budget_voting_rule_threshold_value_setting,
                 :budget_voting_rule_minimum_value_setting,
                 :budget_voting_rule_projects_value_setting

        private

        # Validations on budget settings:
        # - a voting rule must be enabled.
        def budget_voting_rule_enabled_setting
          return unless manifest&.name == :budgets

          rule_settings = [
            :vote_rule_threshold_percent_enabled,
            :vote_rule_minimum_budget_projects_enabled,
            :vote_rule_selected_projects_enabled
          ]
          active_rules = rule_settings.select { |key| settings.public_send(key) == true }
          i18n_error_scope = "decidim.components.budgets.settings.global.form.errors"
          if active_rules.blank?
            rule_settings.each do |key|
              settings.errors.add(key, I18n.t(:budget_voting_rule_required, scope: i18n_error_scope))
            end
          end

          if active_rules.length > 1
            rule_settings.each do |key|
              settings.errors.add(key, I18n.t(:budget_voting_rule_only_one, scope: i18n_error_scope))
            end
          end
        end

        # - the value must be a valid number
        def budget_voting_rule_threshold_value_setting
          return unless manifest&.name == :budgets
          return unless settings.vote_rule_threshold_percent_enabled

          invalid_percent_number = settings.vote_threshold_percent.blank? || settings.vote_threshold_percent.to_i.negative?
          settings.errors.add(:vote_threshold_percent) if invalid_percent_number
        end

        def budget_voting_rule_minimum_value_setting
          return unless manifest&.name == :budgets
          return unless settings.vote_rule_minimum_budget_projects_enabled

          invalid_minimum_number = settings.vote_minimum_budget_projects_number.blank? || (settings.vote_minimum_budget_projects_number.to_i < 1)
          settings.errors.add(:vote_minimum_budget_projects_number) if invalid_minimum_number
        end

        def budget_voting_rule_projects_value_setting
          return unless manifest&.name == :budgets
          return unless settings.vote_rule_selected_projects_enabled

          budget_voting_projects_value_setting_min
          budget_voting_projects_value_setting_max
          budget_voting_projects_value_setting_both
        end

        def budget_voting_projects_value_setting_min
          return if settings.vote_selected_projects_minimum.present? && settings.vote_selected_projects_minimum.to_i >= 0

          settings.errors.add(:vote_selected_projects_minimum)
        end

        def budget_voting_projects_value_setting_max
          return if settings.vote_selected_projects_maximum.present? && settings.vote_selected_projects_maximum.to_i.positive?

          settings.errors.add(:vote_selected_projects_maximum)
        end

        def budget_voting_projects_value_setting_both
          return if settings.errors[:vote_selected_projects_minimum].present?
          return if settings.errors[:vote_selected_projects_maximum].present?
          return if settings.vote_selected_projects_maximum >= settings.vote_selected_projects_minimum

          settings.errors.add(:vote_selected_projects_minimum)
          settings.errors.add(:vote_selected_projects_maximum)
        end
      end
    end
  end
end
