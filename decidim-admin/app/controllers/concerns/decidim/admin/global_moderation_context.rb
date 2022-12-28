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

        # Private: finds the moderations the current user can manage, taking into
        # account whether the user is an organization-wide admin or a
        # "participatory space admin".
        #
        # Returns an `ActiveRecord::Relation`
        def moderations_for_user
          @moderations_for_user ||= Decidim::Admin::ModerationStats.new(current_user).content_moderations
        end
      end
    end
  end
end
