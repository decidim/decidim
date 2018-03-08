# frozen_string_literal: true

module Decidim
  module Budgets
    module AdminLog
      # This class holds the logic to present a `Decidim::Budgets::Project``
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ProjectPresenter.new(action_log, view_helpers).present
      class ProjectPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.budgets.admin_log.project.#{action}"
          else
            super
          end
        end

        def diff_fields_mapping
          {
            budget: :currency,
            description: :i18n,
            title: :i18n,
            decidim_scope_id: :scope
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.project"
        end
      end
    end
  end
end
