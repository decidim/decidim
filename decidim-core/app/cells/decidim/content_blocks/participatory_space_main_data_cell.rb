# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceMainDataCell < BaseCell
      DEFAULT_MAX_LAST_ACTIVITY_USERS = 6

      def nav_links
        return if nav_items.blank?

        render :nav_links
      end

      private

      def title; end

      def description_text; end

      def details_path; end

      def classes_prefix; end

      def nav_items
        []
      end

      def metadata_items
        []
      end

      def max_last_activity_users
        DEFAULT_MAX_LAST_ACTIVITY_USERS
      end

      def last_activities_users
        subquery = Decidim::ParticipatorySpaceLastActivity
                   .new(resource).query
                   .where.not(user: nil)
                   .reorder(decidim_user_id: :asc, created_at: :desc)
                   .select("DISTINCT ON (decidim_user_id) decidim_user_id, created_at")
                   .to_sql
        main_query = Arel.sql("SELECT * FROM (#{subquery}) as q order by created_at DESC limit #{max_last_activity_users}")

        Decidim::User.where(id: ActiveRecord::Base.connection.execute(main_query).field_values("decidim_user_id"))
      end

      def prefixed_class(name)
        [classes_prefix, name].compact.join("__")
      end
    end
  end
end
