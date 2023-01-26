# frozen_string_literal: true

module Decidim
  module Admin
    class ModerationStats
      def initialize(user)
        @user = user
      end

      def content_moderations
        @content_moderations ||= Decidim::Moderation.where(participatory_space: spaces_user_is_admin_to)
      end

      def user_reports
        @user_reports ||= UserModeration.joins(:user).where(decidim_users: { decidim_organization_id: user.decidim_organization_id })
      end

      def count_content_moderations
        content_moderations.not_hidden.count
      end

      def count_user_pending_reports
        user_reports.unblocked.count
      end

      def count_pending_moderations
        count_content_moderations + count_user_pending_reports
      end

      private

      attr_reader :user

      # Private: Finds the participatory spaces the current user is admin to.
      # This method will later be used to find out what moderations the
      # current user can manage.
      #
      # Returns an Array.
      def spaces_user_is_admin_to
        @spaces_user_is_admin_to ||=
          Decidim.participatory_space_manifests.flat_map do |manifest|
            Decidim
              .find_participatory_space_manifest(manifest.name)
              .participatory_spaces
              .call(user.organization)&.select do |space|
              space.moderators.exists?(id: user.id) ||
                space.admins.exists?(id: user.id)
            end
          end
      end
    end
  end
end
