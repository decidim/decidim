# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::Taxonomy`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you should not need to call this class
    # directly, but here is an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    TaxonomyPresenter.new(action_log, view_helpers).present
    class TaxonomyPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          name: :i18n,
          parent_id: :taxonomy
        }
      end

      def action_string
        case action
        when "create", "delete", "update"
          if parent_name.present?
            "decidim.admin_log.taxonomy.#{action}_with_parent"
          else
            "decidim.admin_log.taxonomy.#{action}"
          end
        else
          super
        end
      end

      def i18n_params
        super.merge(
          parent_taxonomy: h.translated_attribute(parent_name)
        )
      end

      def parent_name
        action_log.extra.dig("extra", "parent_name")
      end
    end
  end
end
