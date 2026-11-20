# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class DashboardController < Decidim::Admin::ApplicationController
      helper_method :latest_action_logs
      helper_method :users_counter
      helper_method :count_pending_moderations

      def show
        enforce_permission_to :read, :admin_dashboard
      end

      private

      def count_pending_moderations
        @count_pending_moderations ||= Decidim::Admin::ModerationStats.new(current_user).count_pending_moderations
      end

      def latest_action_logs
        @latest_action_logs ||= begin
          logs = Decidim::ActionLog
                 .where(organization: current_organization)
                 .includes(:participatory_space, :user, :resource, :component, version: :item)
                 .for_admin
                 .order(created_at: :desc)
                 .first(5)

          preload_resource_components(logs)
          logs
        end
      end

      # Private: `resource` is a polymorphic association, so Rails cannot eager
      # load the `component` of the resources together with it, even though the
      # log presenters need it (and the space and organization behind it) to
      # build the path to each logged resource. Grouping the loaded resources by
      # type keeps the loading to one query per resource type instead of one
      # query per log.
      def preload_resource_components(logs)
        logs.group_by(&:resource_type).each do |resource_type, group|
          klass = resource_type.safe_constantize
          next unless klass.respond_to?(:reflect_on_association) && klass.reflect_on_association(:component)

          records = group.map(&:resource).compact
          next if records.empty?

          ActiveRecord::Associations::Preloader.new(
            records:,
            associations: { component: { participatory_space: :organization } }
          ).call
        end
      end

      def users_counter
        last_day = Time.zone.yesterday
        last_week = Time.zone.today.prev_week
        last_month = Time.zone.today.prev_month

        {
          total_admins_last_day: users_count(last_day, true),
          total_admins_last_week: users_count(last_week, true),
          total_admins_last_month: users_count(last_month, true),
          total_participants_last_day: users_count(last_day, false),
          total_participants_last_week: users_count(last_week, false),
          total_participants_last_month: users_count(last_month, false)
        }
      end

      def users_count(date, admin)
        @users_count = Decidim::Admin::ActiveUsersCounter.new(
          organization: current_organization,
          date:,
          admin:
        ).query.count
      end
    end
  end
end
