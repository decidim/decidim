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
    #    TaxonomyFilterPresenter.new(action_log, view_helpers).present
    class TaxonomyFilterPresenter < Decidim::Log::BasePresenter
      include Decidim::SanitizeHelper

      private

      def diff_fields_mapping
        {
          name: :i18n,
          internal_name: :i18n,
          root_taxonomy_id: :taxonomy,
          participatory_space_manifests: :array
        }
      end

      def action_string
        case action
        when "create", "delete", "update"
          if filter_items_count.present? && taxonomy_name.present?
            "decidim.admin_log.taxonomy_filter.#{action}_with_filter_info"
          else
            "decidim.admin_log.taxonomy_filter.#{action}"
          end
        else
          super
        end
      end

      def i18n_params
        super.merge(
          filter_items_count:,
          taxonomy_name: decidim_escape_translated(taxonomy_name)
        )
      end

      def filter_items_count
        action_log.extra.dig("extra", "filter_items_count")
      end

      def taxonomy_name
        action_log.extra.dig("extra", "taxonomy_name")
      end
    end
  end
end
