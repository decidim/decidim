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
      private

      def diff_fields_mapping
        {
          root_taxonomy_id: :taxonomy,
          space_manifest: :string
        }
      end

      def action_string
        case action
        when "create", "delete", "update"
          if filter_items_count.present?
            "decidim.admin_log.taxonomy_filter.#{action}_with_filter_items_count"
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
          space_manifest_name:
        )
      end

      def filter_items_count
        action_log.extra.dig("extra", "filter_items_count")
      end

      def space_manifest_name
        return unless (manifest_name = action_log.extra.dig("extra", "space_manifest"))

        I18n.t("menu.#{manifest_name}", scope: "decidim.admin", default: manifest_name)
      end
    end
  end
end
