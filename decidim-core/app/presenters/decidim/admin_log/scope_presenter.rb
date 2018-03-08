# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::Scope`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    ScopePresenter.new(action_log, view_helpers).present
    class ScopePresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          code: :string,
          name: :i18n,
          parent_id: :scope,
          scope_type_id: :scope_type
        }
      end

      def action_string
        case action
        when "create", "delete", "update"
          if parent_name.present?
            "decidim.admin_log.scope.#{action}_with_parent"
          else
            "decidim.admin_log.scope.#{action}"
          end
        else
          super
        end
      end

      def i18n_labels_scope
        "activemodel.attributes.scope"
      end

      def i18n_params
        super.merge(
          parent_scope: h.translated_attribute(parent_name)
        )
      end

      def parent_name
        action_log.extra.dig("extra", "parent_name")
      end
    end
  end
end
