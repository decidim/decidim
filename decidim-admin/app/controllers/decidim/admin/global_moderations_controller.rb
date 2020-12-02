# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admin users to manage all moderations from the
    # participatory spaces they have access to.
    class GlobalModerationsController < Decidim::Admin::ModerationsController
      layout "decidim/admin/global_moderations"

      # Private: This method is used by the `Filterable` concern as the base query
      # without applying filtering and/or sorting options.
      def collection
        @collection ||=
          if params[:hidden]
            moderations_for_user.where.not(hidden_at: nil)
          else
            moderations_for_user.where(hidden_at: nil)
          end
      end

      # Private: Finds the participatory spaces the current user is admin to.
      # This is only used for users that are "participatoy space admins", not
      # organization-wide admins. This method will later be used to find out
      # what moderations can the current user manage.
      #
      # Returns an Array.
      def spaces_user_is_admin_to
        @spaces_user_is_admin_to ||=
          Decidim.participatory_space_manifests.flat_map do |manifest|
            Decidim
              .find_participatory_space_manifest(manifest.name)
              .participatory_spaces
              .call(organization)&.select do |space|
                space.admins.exists?(id: user.id)
              end
          end
      end

      # Private: finds the moderations the current user can manage, taking into
      # account whether the user is an organization-wide admin or a
      # "participatory space admin".
      #
      # Returns an `ActiveRecord::Relation`
      def moderations_for_user
        @moderations_for_user ||=
          if current_user.admin?
            Decidim::Moderation.all
          else
            Decidim::Moderation.where(participatory_space: spaces_user_is_admin_to)
          end
      end

      # Private: fins the reportable of the specific moderation the user is
      # trying to manage.
      #
      # Returns a resource implementing the `Decidim::Reportable` concern.
      def reportable
        @reportable ||= moderations_for_user.find(params[:id]).reportable
      end

      # Private: Overwrites the method from the parent controller so that the
      # permission system does not overwrite permissions.
      def permission_resource
        :global_moderation
      end
    end
  end
end
