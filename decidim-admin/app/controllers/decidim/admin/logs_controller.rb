# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class LogsController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Logs::Filterable

      helper_method :logs, :no_logs_available?

      # The action logs are too complicated to be eagerly loaded
      # we may have a Decidim::Meetings::Meeting resource to which we can eagerly load component: { participatory_space: :organization }
      # We may have a Decidim::Comments::Comment resource to which we caan eagerly load :commentable, :root_commentable with associated children
      # We may have a Decidim::Component resource that does not respond to component and so on
      # We may have a Decidim::Parocess resource that does not have an collection
      # Calling .includes() with all the possible combinations, could raise a `ActiveRecord::AssociationNotFoundError`
      around_action :skip_bullet, if: -> { defined?(::Bullet) }

      def index
        enforce_permission_to :read, :admin_log
      end

      private

      def logs
        @logs ||= filtered_collection.order(created_at: :desc)
      end

      def no_logs_available?
        root_query.none?
      end

      def base_query
        root_query.includes(:organization, :component, :user, :resource, :participatory_space, version: :item)
      end

      def root_query
        Decidim::ActionLog.where(
          organization: current_organization
        ).for_admin
      end

      private

      # This method is presented in Bullet readme, but is not yet available in Bullet 8.1.3.
      # https://github.com/flyerhzm/bullet/issues/505
      def skip_bullet
        return Bullet.skip { yield } if Bullet.respond_to?(:skip)

        previous_value = Bullet.enable?
        Bullet.enable = false
        yield
      ensure
        Bullet.enable = previous_value
      end
    end
  end
end
