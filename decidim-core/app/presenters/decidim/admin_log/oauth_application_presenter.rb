# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::OAuthApplication`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    OAuthApplicationPresenter.new(action_log, view_helpers).present
    class OAuthApplicationPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          name: :string,
          organization_name: :string,
          organization_url: :string,
          organization_logo: :string,
          redirect_uri: :string
        }
      end

      def action_string
        case action
        when "create", "delete", "update"
          "decidim.admin_log.oauth_application.#{action}"
        else
          super
        end
      end

      def i18n_labels_scope
        "activemodel.attributes.oauth_application"
      end

      # Private: Caches the object that will be responsible of presenting the OAuthApplication.
      # Overwrites the method so that we can use a custom presenter to show the correct
      # path for the OAuthApplication.
      #
      # Returns an object that responds to `present`.
      def resource_presenter
        @resource_presenter ||= Decidim::AdminLog::OAuthApplicationResourcePresenter.new(action_log.resource, h, action_log.extra["resource"])
      end
    end
  end
end
