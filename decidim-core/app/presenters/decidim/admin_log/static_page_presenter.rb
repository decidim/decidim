# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::StaticPage`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    StaticPagePresenter.new(action_log, view_helpers).present
    class StaticPagePresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          content: :i18n,
          slug: :default,
          title: :i18n
        }
      end

      # Private: Caches the object that will be responsible of presenting the static page.
      # Overwrites the method so that we can use a custom presenter to show the correct
      # path for ther page.
      #
      # Returns an object that responds to `present`.
      def resource_presenter
        @resource_presenter ||= Decidim::AdminLog::StaticPageResourcePresenter.new(action_log.resource, h, action_log.extra["resource"])
      end

      def i18n_labels_scope
        "activemodel.attributes.static_page"
      end

      def action_string
        case action
        when "create", "delete", "update"
          "decidim.admin_log.static_page.#{action}"
        else
          super
        end
      end
    end
  end
end
