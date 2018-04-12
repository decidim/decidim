# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::Feature`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    FeaturePresenter.new(action_log, view_helpers).present
    class FeaturePresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          name: :i18n,
          published_at: :date,
          weight: :integer
        }
      end

      def i18n_labels_scope
        "activemodel.attributes.feature"
      end

      def action_string
        case action
        when "create", "delete", "publish", "unpublish"
          "decidim.admin_log.feature.#{action}"
        else
          super
        end
      end

      def has_diff?
        action == "unpublish" || super
      end
    end
  end
end
