# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    module GlobalModerationContext
      extend ActiveSupport::Concern

      included do
        # Private: Overwrites the method from the parent controller so that the
        # permission system does not overwrite permissions.
        def permission_resource
          :global_moderation
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
                .call(current_organization)&.select do |space|
                  space.moderators.exists?(id: current_user.id)
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
      end
    end
  end
end
