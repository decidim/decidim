# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceLastActivityCell < BaseCell
      def render_recent_avatars
        return if last_activities_users.blank?

        render :recent_avatars
      end

      def participants_count
        @participants_count ||= activities_query.select(:user_id).distinct.count
      end

      def activities_query
        @activities_query ||= Decidim::ParticipatorySpaceLastActivity.new(resource).query
      end

      private

      def ordered_users_with_activities
        @ordered_users_with_activities ||=
          Decidim::ParticipatorySpaceLastActivity
          .new(resource).query
          .where.not(user: nil)
          .select("user_id, MAX(decidim_action_logs.created_at)")
          .group("user_id")
          .reorder("MAX(decidim_action_logs.created_at) DESC")
      end

      def last_activities_users
        @last_activities_users ||= ordered_users_with_activities.limit(max_last_activity_users).map(&:user)
      end

      def max_last_activity_users
        model.settings.try(:max_last_activity_users) || Decidim.default_max_last_activity_users
      end

      def hide_participatory_space = true
    end
  end
end
